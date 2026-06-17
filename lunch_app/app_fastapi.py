from fastapi import Request, Form, FastAPI, HTTPException, Depends, UploadFile, File
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from datetime import datetime, time
from contextlib import asynccontextmanager
from typing import AsyncGenerator
import threading
import shutil
import os

from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, func, select, delete
from sqlalchemy.orm import DeclarativeBase, relationship
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

os.makedirs("static/uploads", exist_ok=True)

DB_URL = (
    f"postgresql+asyncpg://"
    f"{os.getenv('DB_USER', 'scott')}:"       
    f"{os.getenv('DB_PASSWORD', 'tiger')}@"   
    f"{os.getenv('DB_HOST', 'localhost')}:"   
    f"{os.getenv('DB_PORT', '5432')}/"        
    f"{os.getenv('DB_NAME', 'lunch_db')}"     
)

engine = create_async_engine(DB_URL, echo=False, pool_size=10, max_overflow=5)
SessionLocal = async_sessionmaker(engine, expire_on_commit=False)

class Base(DeclarativeBase):
    pass

class Member(Base):
    __tablename__ = "members"
    employee_id = Column(String(20), primary_key=True)   
    name        = Column(String(50),  nullable=False)
    password    = Column(String(50),  nullable=False, default="1234")    
    department  = Column(String(50))                     
    created_at  = Column(DateTime, default=datetime.now) 
    reservations = relationship("Reservation", back_populates="member")

class Reservation(Base):
    __tablename__ = "reservations"
    id          = Column(Integer, primary_key=True, autoincrement=True)
    employee_id = Column(String(20), ForeignKey("members.employee_id"), nullable=False)  
    menu_id     = Column(Integer, nullable=False)
    menu_name   = Column(String(100), nullable=False)
    reserved_at = Column(DateTime, default=datetime.now)
    member = relationship("Member", back_populates="reservations")

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with SessionLocal() as session:
        yield session  

@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with SessionLocal() as session:
        existing = await session.execute(select(Member))
        if not existing.scalars().first():
            session.add_all([
                Member(employee_id="EMP001", name="김철수", password="1234", department="개발팀"),
                Member(employee_id="EMP002", name="이영희", password="1234", department="마케팅팀"),
                Member(employee_id="EMP003", name="박민준", password="1234", department="인사팀"),
                Member(employee_id="EMP004", name="최지은", password="1234", department="디자인팀"),
                Member(employee_id="EMP005", name="정수현", password="1234", department="영업팀"),
            ])
            await session.commit()
    yield  
    await engine.dispose()

app = FastAPI(title="사내 점심 예약 시스템", lifespan=lifespan)

app.add_middleware(SessionMiddleware, secret_key="super-secret-key")
templates = Jinja2Templates(directory="templates")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_methods=["*"],
    allow_headers=["*"],
)

lock = threading.Lock()
DEADLINE = time(11, 30)

menus = [
    {"id": 1, "name": "제육볶음 도시락", "description": "매콤한 제육볶음과 다양한 반찬",     "kcal": 560, "total": 50, "remaining": 28, "is_popular": True, "badge": None, "badge_type": None, "emoji": "🥩", "image_url": None, "price": 8500},
    {"id": 2, "name": "치킨마요 덮밥",   "description": "고소한 치킨마요 소스와 튼튼한 덮밥", "kcal": 610, "total": 50, "remaining": 32, "is_popular": True, "badge": None, "badge_type": None, "emoji": "🍗", "image_url": None, "price": 7500},
    {"id": 3, "name": "김치볶음밥",       "description": "매콤한 김치볶음밥과 계란후라이",    "kcal": 590, "total": 30, "remaining": 15, "is_popular": False, "badge": None, "badge_type": None, "emoji": "🍳", "image_url": None, "price": 7000},
    {"id": 4, "name": "돈까스 도시락",    "description": "바삭한 돈까스와 신선한 샐러드",     "kcal": 650, "total": 40, "remaining": 18, "is_popular": False, "badge": None, "badge_type": None, "emoji": "🍱", "image_url": None, "price": 9000},
]

def update_badge(menu):
    r = menu["remaining"]
    if r == 0:
        menu["badge"], menu["badge_type"] = "품절", "soldout"
    elif r <= 5:
        menu["badge"], menu["badge_type"] = "마감 임박", "urgent"
    elif menu.get("is_popular", False):
        menu["badge"], menu["badge_type"] = "인기 메뉴", "popular"
    else:
        menu["badge"], menu["badge_type"] = None, None

for m in menus:
    update_badge(m)

class ReserveRequest(BaseModel):
    menu_id: int

class AdminLoginRequest(BaseModel):
    admin_id: str
    admin_pw: str

class MenuAddRequest(BaseModel):
    name: str
    description: str
    kcal: int
    total: int
    emoji: str

class MenuUpdateRequest(BaseModel):
    total: int
    remaining: int
    is_popular: bool

class MemberRequest(BaseModel):
    employee_id: str
    name: str
    password: str
    department: str

class MemberUpdateRequest(BaseModel):
    name: str
    password: str
    department: str

def is_open():
    return datetime.now().time() < DEADLINE

@app.get("/", response_class=HTMLResponse)
async def login_page(request: Request):
    return templates.TemplateResponse(request=request, name="login.html")

@app.post("/login")
async def login(
    request: Request,
    emp_no: str = Form(...),
    password: str = Form(...),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Member).where(Member.employee_id == emp_no, Member.password == password))
    user = result.scalars().first()

    if user:
        request.session["employee_id"] = user.employee_id
        request.session["name"] = user.name
        request.session["department"] = user.department
        return RedirectResponse(url="/reserve", status_code=303)
    else:
        return RedirectResponse(url="/?error=invalid", status_code=303)

@app.post("/api/logout")
async def logout_employee(request: Request):
    request.session.pop("employee_id", None)
    request.session.pop("name", None)
    request.session.pop("department", None)
    return {"success": True}

@app.get("/reserve", response_class=HTMLResponse)
async def reserve_page(request: Request):
    if not request.session.get("employee_id"):
        return RedirectResponse(url="/", status_code=303)
    return templates.TemplateResponse(request=request, name="reserve.html")

@app.get("/api/menus")
def get_menus():
    return {"menus": menus, "deadline": "11:30 AM", "total_remaining": sum(m["remaining"] for m in menus), "is_open": is_open()}

@app.post("/api/reserve")
async def reserve(req: ReserveRequest, request: Request, db: AsyncSession = Depends(get_db)):
    emp = request.session.get("employee_id")
    name = request.session.get("name")

    if not emp or not name:
        raise HTTPException(401, "세션이 만료되었거나 로그인이 필요합니다.")

    dup = await db.execute(select(Reservation).where(Reservation.employee_id == emp, func.date(Reservation.reserved_at) == datetime.now().date()))
    existing = dup.scalars().first()

    if existing:
        raise HTTPException(400, f"오늘 이미 예약하셨습니다. ({existing.menu_name})")
    
    with lock:
        global menus
        menu = next((m for m in menus if m["id"] == req.menu_id), None)
        if not menu:
            raise HTTPException(404, "메뉴를 찾을 수 없습니다.")
        if menu["remaining"] <= 0:
            raise HTTPException(400, "해당 메뉴는 품절되었습니다.")
        menu["remaining"] -= 1
        update_badge(menu)

    now = datetime.now()
    reservation = Reservation(employee_id=emp, menu_id=menu["id"], menu_name=menu["name"], reserved_at=now)
    db.add(reservation)
    await db.commit()

    return {
        "success": True,
        "message": f"'{menu['name']}' 예약이 완료되었습니다!",
        "reservation": {
            "id": reservation.id, "menu_id": menu["id"], "menu_name": menu["name"],
            "name": name, "employee_id": emp, "reserved_at": now.strftime("%Y-%m-%d %H:%M:%S")
        }
    }

@app.get("/api/my-reservation")
async def my_reservation(request: Request, db: AsyncSession = Depends(get_db)):
    emp = request.session.get("employee_id")
    name = request.session.get("name")
    if not emp:
        return {"success": False}
        
    result = await db.execute(select(Reservation).where(Reservation.employee_id == emp, func.date(Reservation.reserved_at) == datetime.now().date()))
    reservation = result.scalars().first()
    
    if not reservation:
        return {"success": False, "reservation": None}
        
    return {
        "success": True,
        "reservation": {
            "id": reservation.id, "menu_id": reservation.menu_id, "menu_name": reservation.menu_name, "name": name, "employee_id": emp, "reserved_at": reservation.reserved_at.strftime("%Y-%m-%d %H:%M:%S")
        }
    }

@app.post("/api/cancel")
async def cancel(request: Request, db: AsyncSession = Depends(get_db)):
    emp = request.session.get("employee_id")
    if not emp:
        raise HTTPException(401, "세션이 만료되었습니다.")
        
    result = await db.execute(select(Reservation).where(Reservation.employee_id == emp, func.date(Reservation.reserved_at) == datetime.now().date()))
    reservation = result.scalars().first()
    
    if not reservation:
        raise HTTPException(404, "오늘 예약 내역이 없습니다.")
        
    await db.delete(reservation)
    await db.commit()
    
    with lock:
        global menus
        menu = next((m for m in menus if m["id"] == reservation.menu_id), None)
        if menu:
            menu["remaining"] += 1
            update_badge(menu)
            
    return {"success": True, "message": "예약이 취소되었습니다."}

@app.post("/api/admin/login")
async def admin_login(req: AdminLoginRequest, request: Request):
    if req.admin_id == "admin" and req.admin_pw == "admin":
        request.session["is_admin"] = True
        return {"success": True}
    return {"success": False, "message": "관리자 정보가 일치하지 않습니다."}

@app.get("/admin", response_class=HTMLResponse)
async def admin_page(request: Request):
    if not request.session.get("is_admin"):
        return RedirectResponse(url="/", status_code=303)
    return templates.TemplateResponse(request=request, name="admin.html")

@app.get("/api/admin/dashboard")
async def admin_dashboard(request: Request, db: AsyncSession = Depends(get_db)):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
    
    # DB에서 오늘 실제 예약 건수 직접 조회
    today_count_result = await db.execute(
        select(func.count(Reservation.id)).where(
            func.date(Reservation.reserved_at) == datetime.now().date()
        )
    )
    total_reserved = today_count_result.scalar()
    
    total_capacity = sum(m["total"] for m in menus)
    total_remaining = sum(m["remaining"] for m in menus)
    
    return {
        "success": True,
        "total_capacity": total_capacity,
        "total_reserved": total_reserved,
        "total_remaining": total_remaining,
        "menus": menus
    }
    
    return {
        "success": True,
        "total_capacity": total_capacity,
        "total_reserved": total_reserved,
        "total_remaining": total_remaining,
        "menus": menus
    }

@app.post("/api/admin/menus")
async def admin_add_menu(req: MenuAddRequest, request: Request):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
    
    with lock:
        global menus
        new_id = max([m["id"] for m in menus], default=0) + 1
        new_menu = {
            "id": new_id,
            "name": req.name,
            "description": req.description,
            "kcal": req.kcal,
            "total": req.total,
            "remaining": req.total,
            "is_popular": False,
            "badge": None,
            "badge_type": None,
            "emoji": req.emoji,
            "image_url": None,
            "price": 0
        }
        menus.append(new_menu)
        update_badge(new_menu)
    return {"success": True}

@app.put("/api/admin/menus/{menu_id}")
async def admin_update_menu(menu_id: int, req: MenuUpdateRequest, request: Request):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
    
    with lock:
        global menus
        menu = next((m for m in menus if m["id"] == menu_id), None)
        if not menu:
            raise HTTPException(404, "메뉴를 찾을 수 없습니다.")
        menu["total"] = req.total
        menu["remaining"] = req.remaining
        menu["is_popular"] = req.is_popular
        update_badge(menu)
    return {"success": True}

@app.delete("/api/admin/menus/{menu_id}")
async def admin_delete_menu(menu_id: int, request: Request):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
        
    with lock:
        global menus
        menu = next((m for m in menus if m["id"] == menu_id), None)
        if not menu:
            raise HTTPException(404, "메뉴를 찾을 수 없습니다.")
        menus.remove(menu)
    return {"success": True}

@app.post("/api/admin/menus/{menu_id}/image")
async def admin_upload_menu_image(menu_id: int, request: Request, file: UploadFile = File(...)):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
    
    with lock:
        global menus
        menu = next((m for m in menus if m["id"] == menu_id), None)
        if not menu:
            raise HTTPException(404, "메뉴를 찾을 수 없습니다.")
        
        file_ext = os.path.splitext(file.filename)[1]
        file_name = f"menu_{menu_id}_{int(datetime.now().timestamp())}{file_ext}"
        file_path = f"static/uploads/{file_name}"
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        menu["image_url"] = f"/{file_path}"
        
    return {"success": True, "image_url": menu["image_url"]}

@app.delete("/api/admin/menus/{menu_id}/image")
async def admin_delete_menu_image(menu_id: int, request: Request):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
    
    with lock:
        global menus
        menu = next((m for m in menus if m["id"] == menu_id), None)
        if not menu:
            raise HTTPException(404, "메뉴를 찾을 수 없습니다.")
        menu["image_url"] = None
        
    return {"success": True}

@app.get("/api/admin/members")
async def admin_get_members(request: Request, db: AsyncSession = Depends(get_db)):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
    result = await db.execute(select(Member).order_by(Member.employee_id))
    members = result.scalars().all()
    return {"success": True, "members": [{"employee_id": m.employee_id, "name": m.name, "password": m.password, "department": m.department} for m in members]}

@app.post("/api/admin/members")
async def admin_add_member(req: MemberRequest, request: Request, db: AsyncSession = Depends(get_db)):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
    existing = await db.execute(select(Member).where(Member.employee_id == req.employee_id))
    if existing.scalars().first():
        return {"success": False, "message": "이미 등록된 사원번호입니다."}
    
    new_member = Member(employee_id=req.employee_id, name=req.name, password=req.password, department=req.department)
    db.add(new_member)
    await db.commit()
    return {"success": True}

@app.put("/api/admin/members/{emp_id}")
async def admin_update_member(emp_id: str, req: MemberUpdateRequest, request: Request, db: AsyncSession = Depends(get_db)):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
    result = await db.execute(select(Member).where(Member.employee_id == emp_id))
    member = result.scalars().first()
    if not member:
        return {"success": False, "message": "사원을 찾을 수 없습니다."}
    
    member.name = req.name
    member.password = req.password
    member.department = req.department
    await db.commit()
    return {"success": True}

@app.delete("/api/admin/members/{emp_id}")
async def admin_delete_member(emp_id: str, request: Request, db: AsyncSession = Depends(get_db)):
    if not request.session.get("is_admin"):
        raise HTTPException(401)
    result = await db.execute(select(Member).where(Member.employee_id == emp_id))
    member = result.scalars().first()
    if not member:
        return {"success": False, "message": "사원을 찾을 수 없습니다."}
    
    await db.execute(delete(Reservation).where(Reservation.employee_id == emp_id))
    await db.delete(member)
    await db.commit()
    return {"success": True}

@app.post("/api/admin/logout")
async def admin_logout(request: Request):
    request.session.pop("is_admin", None)
    return {"success": True}

app.mount("/static", StaticFiles(directory="static"), name="static")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app_fastapi:app", host="0.0.0.0", port=8000, reload=True)