const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// --- เปิด database ---
const db = new sqlite3.Database('./mydatabase.db');

// --- สร้างตารางต่างๆ 
db.serialize(() => {
  // ตารางแผนเที่ยว
  db.run(`
    CREATE TABLE IF NOT EXISTS plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE,  
  province TEXT,
  start_date TEXT,
  end_date TEXT,
  budget REAL,
  spending REAL,
  dayColors TEXT
)

  `);

  // ตารางสถานที่ในแผนแบบ minimal:
  // เปลี่ยนจากการเก็บข้อมูลเต็ม (name, lat, lon) เป็นเก็บเฉพาะ place_id
  db.run(`
    CREATE TABLE IF NOT EXISTS places (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plan_id INTEGER,
      day_index INTEGER,
      place_id INTEGER,
      expense REAL,
      order_index INTEGER,
      category TEXT
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS favorite_places (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plan_id INTEGER,
      name TEXT,
      lat REAL,
      lon REAL,
      category TEXT
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS other_expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      plan_id INTEGER,
      desc TEXT,
      amount REAL,
      icon_code INTEGER
    )
  `);
});

db.run(`
  CREATE TABLE IF NOT EXISTS all_places (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    lat REAL,
    lon REAL,
    category TEXT,
    province TEXT,
    image TEXT,
    openingDays TEXT,
    phone TEXT
  )
`);

// ---  เพิ่มข้อมูล mockPlaces ลงใน all_places  ---
const mockPlaces = [
  {
    'name': 'จ้วด คาเฟ่',
    'lat': 16.4351,
    'lon': 102.8283,
    'category': 'food',
    'province': 'ขอนแก่น',
    'image': 'assets/images/Cafe.jpg', 
  },
  {
    'name': 'ไก่ย่างระเบียบ',
    'lat': 16.4378,
    'lon': 102.8320,
    'category': 'food',
    'province': 'ขอนแก่น',
    'image': 'assets/images/Res4.webp', 
  },
  {
    'name': 'ร้านอาหารเด้อหล่าแจ๊ส Der La Jazz',
    'lat': 16.4335,
    'lon': 102.8239,
    'category': 'food',
    'province': 'ขอนแก่น',
    'image': 'assets/images/Res2.jpg',
    'openingDays': 'จันทร์ อังคาร พุธ พฤหัส ศุกร์ เสาร์',
    'phone': '081-225-5589',
  },
  {
    'name': 'โรงแรมพูลแมน',
    'lat': 16.4289,
    'lon': 102.8333,
    'category': 'hotel',
    'province': 'ขอนแก่น',
  },
  {
    'name': 'Ad Lib Khon Kaen',
    'lat': 16.4305,
    'lon': 102.8279,
    'category': 'hotel',
    'province': 'ขอนแก่น',
  },
  {
    'name': 'บึงแก่นนคร',
    'lat': 16.4202,
    'lon': 102.8347,
    'category': 'tourist',
    'province': 'ขอนแก่น',
  },
  {
    'name': 'ตลาดต้นตาล',
    'lat': 16.4253,
    'lon': 102.8239,
    'category': 'tourist',
    'province': 'ขอนแก่น',
  },
];

mockPlaces.forEach((place) => {
  db.get(`SELECT * FROM all_places WHERE name = ?`, [place.name], (err, row) => {
    if (!row) {
      db.run(
        `INSERT INTO all_places (name, lat, lon, category, province, image, openingDays, phone)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          place.name,
          place.lat,
          place.lon,
          place.category,
          place.province,
          place.image || null,
          place.openingDays || null,
          place.phone || null
        ]
      );
    }
  });
});

// --- ✅ API ดึงสถานที่จากจังหวัด ---
app.get('/places', (req, res) => {
  const province = req.query.province;
  db.all(
    `SELECT * FROM all_places WHERE province = ?`,
    [province],
    (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(rows);
    }
  );
});

// --- ข้อมูลพิกัดจังหวัดภาคอีสาน ---
const coords = {
  'กาฬสินธุ์': { lat: 16.4313, lon: 103.5060 },
  'ขอนแก่น': { lat: 16.4322, lon: 102.8236 },
  'ชัยภูมิ': { lat: 15.8067, lon: 102.0315 },
  'นครพนม': { lat: 17.4108, lon: 104.7784 },
  'นครราชสีมา': { lat: 14.9799, lon: 102.0977 },
  'บึงกาฬ': { lat: 18.3609, lon: 103.6465 },
  'บุรีรัมย์': { lat: 14.9946, lon: 103.1036 },
  'มหาสารคาม': { lat: 16.1970, lon: 103.2830 },
  'มุกดาหาร': { lat: 16.5453, lon: 104.7230 },
  'ยโสธร': { lat: 15.7940, lon: 104.1453 },
  'ร้อยเอ็ด': { lat: 16.0567, lon: 103.6531 },
  'เลย': { lat: 17.4860, lon: 101.7220 },
  'สกลนคร': { lat: 17.1620, lon: 104.1476 },
  'สุรินทร์': { lat: 14.8818, lon: 103.4936 },
  'ศรีสะเกษ': { lat: 15.1148, lon: 104.3294 },
  'หนองคาย': { lat: 17.8783, lon: 102.7420 },
  'หนองบัวลำภู': { lat: 17.2220, lon: 102.4260 },
  'อำนาจเจริญ': { lat: 15.8642, lon: 104.6258 },
  'อุดรธานี': { lat: 17.4138, lon: 102.7872 },
  'อุบลราชธานี': { lat: 15.2448, lon: 104.8473 }
};
// ✅ API ดึงสถานที่จาก place_id
app.get('/places/:id', (req, res) => {
  const id = req.params.id;
  db.get(`SELECT * FROM all_places WHERE id = ?`, [id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: 'ไม่พบสถานที่' });
    res.json(row);
  });
});

// --- ✅ API ดึงชื่อจังหวัดทั้งหมด (เฉพาะชื่อ) ---
app.get('/provinces', (req, res) => {
  res.json(Object.keys(coords));
});

// --- ✅ API ดึงพิกัดจังหวัด ---
app.get('/province/location', (req, res) => {
  const provinceName = req.query.name;
  if (coords[provinceName]) {
    res.json({ name: provinceName, ...coords[provinceName] });
  } else {
    res.status(404).json({ error: 'ไม่พบจังหวัดที่ระบุ' });
  }
});

// --- ✅ API แผนทั้งหมด ---
app.get('/plans', (req, res) => {
  db.all('SELECT * FROM plans ORDER BY id DESC', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// --- ✅ API สร้างแผนใหม่ --- 
app.post('/plans', (req, res) => {
  const {
    name, province, start_date, end_date, budget, spending,
    dayColors, favoritePlaces, placesByDay, otherExpenses
  } = req.body;

  db.run(
    `INSERT INTO plans (name, province, start_date, end_date, budget, spending, dayColors)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [name, province, start_date, end_date, budget, spending, JSON.stringify(dayColors || {})],
    function (err) {
      if (err) {
        if (err.message.includes("UNIQUE constraint failed")) {
          return res.status(400).json({ error: 'มีชื่อแผนนี้อยู่แล้ว กรุณาใช้ชื่ออื่น' });
        }
        return res.status(500).json({ error: err.message });
      }

      const planId = this.lastID;

      // --- ✅ เพิ่ม favoritePlaces ---
      if (Array.isArray(favoritePlaces)) {
        const favStmt = db.prepare(
          `INSERT INTO favorite_places (plan_id, name, lat, lon, category) VALUES (?, ?, ?, ?, ?)`
        );
        favoritePlaces.forEach((fav) => {
          favStmt.run(planId, fav.name, fav.lat, fav.lon, fav.category);
        });
        favStmt.finalize();
      }

      // --- ✅ เพิ่ม placesByDay ---
      if (placesByDay && typeof placesByDay === 'object') {
        const placeStmt = db.prepare(
          `INSERT INTO places (plan_id, day_index, place_id, expense, order_index, category)
           VALUES (?, ?, ?, ?, ?, ?)`
        );
        Object.entries(placesByDay).forEach(([day, places]) => {
          places.forEach((place) => {
            placeStmt.run(planId, day, place.place_id, place.expense || 0, place.order_index || 0, place.category);
          });
        });
        placeStmt.finalize();
      }

      // --- ✅ เพิ่ม otherExpenses ---
      if (Array.isArray(otherExpenses)) {
        const expStmt = db.prepare(
          `INSERT INTO other_expenses (plan_id, desc, amount, icon_code)
           VALUES (?, ?, ?, ?)`
        );
        otherExpenses.forEach((exp) => {
          expStmt.run(planId, exp.desc, exp.amount, exp.icon_code || null);
        });
        expStmt.finalize();
      }

      // ✅ ส่ง id กลับ
      res.status(201).json({ id: planId });
    }
  );
});



// --- ✅ API ดึงแผนตาม id (พร้อม places, favorites, expenses) ---
// ใช้ JOIN กับ all_places เพื่อดึงข้อมูลรายละเอียดเต็มของสถานที่
app.get('/plans/:id', (req, res) => {
  const planId = req.params.id;

  db.get('SELECT * FROM plans WHERE id = ?', [planId], (err, plan) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!plan) return res.status(404).json({ error: 'ไม่พบแผนที่ต้องการ' });

    const placesQuery = `
      SELECT 
        p.day_index, 
        p.expense, 
        p.order_index,
        p.category,
        ap.id AS place_id,
        ap.name AS place_name,
        ap.lat,
        ap.lon,
        ap.image,
        ap.openingDays,
        ap.phone
      FROM places p 
      LEFT JOIN all_places ap ON p.place_id = ap.id 
      WHERE p.plan_id = ?
      ORDER BY p.day_index, p.order_index
    `;
    
    db.all(placesQuery, [planId], (err, places) => {
      if (err) return res.status(500).json({ error: err.message });

      const groupedPlaces = {};
      for (const place of places) {
        // หาก record (place) เป็น null หรือไม่มีค่า day_index ให้ข้าม record นั้น
        if (!place || place.day_index == null) {
          continue;
        }
        if (!groupedPlaces[place.day_index]) {
          groupedPlaces[place.day_index] = [];
        }
        groupedPlaces[place.day_index].push(place);
      }

      db.all('SELECT * FROM favorite_places WHERE plan_id = ?', [planId], (err, favorites) => {
        if (err) return res.status(500).json({ error: err.message });

        db.all('SELECT * FROM other_expenses WHERE plan_id = ?', [planId], (err, expenses) => {
          if (err) return res.status(500).json({ error: err.message });

          res.json({
            id: plan.id,
            name: plan.name,
            province: plan.province,
            start_date: plan.start_date,
            end_date: plan.end_date,
            budget: plan.budget,
            spending: plan.spending,
            dayColors: plan.dayColors ? JSON.parse(plan.dayColors) : {},
            favoritePlaces: favorites,
            placesByDay: groupedPlaces,
            otherExpenses: expenses,
          });
        });
      });
    });
  });
});

// --- ✅ API PUT อัปเดตแผนเที่ยว ---
app.put('/plans/:id', (req, res) => {
  const planId = req.params.id;
  const {
    name, province, start_date, end_date, budget, spending,
    dayColors, favoritePlaces, placesByDay, otherExpenses
  } = req.body;

  db.run(
    `UPDATE plans  SET name=?, province=?, start_date=?, end_date=?, budget=?, spending=? WHERE id=?`,
    [name, province, start_date, end_date, budget, spending, planId],
    function (err) {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: 'Failed to update plan' });
      }

      // ✅ ลบของเก่าออกก่อน (กันข้อมูลซ้ำ)
      db.run(`DELETE FROM favorite_places WHERE plan_id = ?`, [planId]);
      db.run(`DELETE FROM places  WHERE plan_id = ?`, [planId]);
      db.run(`DELETE FROM other_expenses WHERE plan_id = ?`, [planId]);

      // ✅ favoritePlaces
      if (Array.isArray(favoritePlaces)) {
        favoritePlaces.forEach(place => {
          db.run(
            `INSERT INTO favorite_places (plan_id, name, lat, lon, category)
             VALUES (?, ?, ?, ?, ?)`,
            [planId, place.name, place.lat, place.lon, place.category]
          );
        });
        
      }

      // ✅ placesByDay
      if (placesByDay && typeof placesByDay === 'object') {
        Object.entries(placesByDay).forEach(([dayIndex, places]) => {
          places.forEach(place => {
            db.run(
              `INSERT INTO places  (plan_id, day_index, place_id, expense, order_index)
               VALUES (?, ?, ?, ?, ?)`,
              [planId, dayIndex, place.place_id, place.expense || 0, place.order_index || 0]
            );
          });
        });
      }

      // ✅ otherExpenses
      if (Array.isArray(otherExpenses)) {
        otherExpenses.forEach(exp => {
          db.run(
            `INSERT INTO other_expenses (plan_id, desc, amount, icon_code)
             VALUES (?, ?, ?, ?)`,
            [planId, exp.desc, exp.amount, exp.icon_code || null]
          );
        });
      }

      // ✅ optional: save dayColors as JSON
      db.run(
        `UPDATE plans SET dayColors = ? WHERE id = ?`,
        [JSON.stringify(dayColors || {}), planId]
      );
      

      res.json({ success: true });
    }
  );
});


// --- ✅ API POST เพิ่มสถานที่ในแผน ---
// รับข้อมูล minimal: plan_id, day_index, place_id, expense, order_index และ category
app.post('/places', (req, res) => {
  const { plan_id, day_index, place_id, expense, order_index, category } = req.body;
  db.run(
    `INSERT INTO places (plan_id, day_index, place_id, expense, order_index, category)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [plan_id, day_index, place_id, expense, order_index, category],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ id: this.lastID });
    }
  );
});

// --- ✅ API POST เพิ่มสถานที่โปรด ---
app.post('/favorites', (req, res) => {
  const { plan_id, name, lat, lon, category } = req.body;
  db.run(
    `INSERT INTO favorite_places (plan_id, name, lat, lon, category)
     VALUES (?, ?, ?, ?, ?)`,
    [plan_id, name, lat, lon, category],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ id: this.lastID });
    }
  );
});

// --- ✅ API POST เพิ่มค่าใช้จ่ายอื่น ๆ ---
app.post('/expenses', (req, res) => {
  const { plan_id, desc, amount, icon_code } = req.body;
  db.run(
    `INSERT INTO other_expenses (plan_id, desc, amount, icon_code)
     VALUES (?, ?, ?, ?)`,
    [plan_id, desc, amount, icon_code],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ id: this.lastID });
    }
  );
});

// --- ✅ API DELETE สถานที่ในแผน (optional ใช้กับปุ่มลบ) ---
app.delete('/places/:id', (req, res) => {
  const placeId = req.params.id;
  db.run('DELETE FROM places WHERE id = ?', [placeId], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.status(200).json({ message: 'ลบสถานที่สำเร็จ' });
  });
});

// --- ✅ API PUT อัปเดตงบประมาณและรายการใช้จ่ายเพิ่มเติม ---
app.put('/plans/:id', (req, res) => {
  const planId = req.params.id;
  const { name, budget, spending, dayColors, favoritePlaces, placesByDay, otherExpenses } = req.body;

  if (!name || name.trim() === '') {
    return res.status(400).json({ error: 'กรุณาระบุชื่อแผน' });
  }

  db.serialize(() => {
    db.run("BEGIN TRANSACTION");

    // 1. อัปเดตข้อมูลหลักในตาราง plans
    db.run(
      `UPDATE plans SET name = ?, budget = ?, spending = ?, dayColors = ? WHERE id = ?`,
      [name, budget, spending, JSON.stringify(dayColors), planId],
      function (err) {
        if (err) {
          db.run("ROLLBACK");
          return res.status(500).json({ error: 'ไม่สามารถอัปเดตแผนได้: ' + err.message });
        }

        // 2. อัปเดต favorite_places
        db.run(`DELETE FROM favorite_places WHERE plan_id = ?`, [planId], (err) => {
          if (err) {
            db.run("ROLLBACK");
            return res.status(500).json({ error: 'ไม่สามารถลบ favorite_places: ' + err.message });
          }

          if (favoritePlaces && Array.isArray(favoritePlaces) && favoritePlaces.length > 0) {
            const favStmt = db.prepare(
              `INSERT INTO favorite_places (plan_id, name, lat, lon, category) VALUES (?, ?, ?, ?, ?)`
            );
            favoritePlaces.forEach(fav => {
              favStmt.run(planId, fav.name, fav.lat, fav.lon, fav.category);
            });
            favStmt.finalize((err) => {
              if (err) {
                db.run("ROLLBACK");
                return res.status(500).json({ error: 'ไม่สามารถเพิ่ม favorite_places: ' + err.message });
              }
            });
          }

          // 3. อัปเดต places (สำหรับ placesByDay)
          db.run(`DELETE FROM places WHERE plan_id = ?`, [planId], (err) => {
            if (err) {
              db.run("ROLLBACK");
              return res.status(500).json({ error: 'ไม่สามารถลบ places: ' + err.message });
            }

            if (placesByDay && typeof placesByDay === 'object') {
              for (let dayKey in placesByDay) {
                const dayRecords = placesByDay[dayKey];
                if (Array.isArray(dayRecords) && dayRecords.length > 0) {
                  const placeStmt = db.prepare(
                    `INSERT INTO places (plan_id, day_index, place_id, expense, order_index, category)
                     VALUES (?, ?, ?, ?, ?, ?)`
                  );
                  dayRecords.forEach(record => {
                    placeStmt.run(planId, dayKey, record.place_id, record.expense, record.order_index, record.category);
                  });
                  placeStmt.finalize((err) => {
                    if (err) {
                      db.run("ROLLBACK");
                      return res.status(500).json({ error: 'ไม่สามารถเพิ่ม places: ' + err.message });
                    }
                  });
                }
              }
            }

            // 4. อัปเดต other_expenses
            db.run(`DELETE FROM other_expenses WHERE plan_id = ?`, [planId], (err) => {
              if (err) {
                db.run("ROLLBACK");
                return res.status(500).json({ error: 'ไม่สามารถลบ other_expenses: ' + err.message });
              }

              if (otherExpenses && Array.isArray(otherExpenses) && otherExpenses.length > 0) {
                const expStmt = db.prepare(
                  `INSERT INTO other_expenses (plan_id, desc, amount, icon_code) VALUES (?, ?, ?, ?)`
                );
                otherExpenses.forEach(exp => {
                  expStmt.run(planId, exp.desc, exp.amount, exp.icon_code);
                });
                expStmt.finalize((err) => {
                  if (err) {
                    db.run("ROLLBACK");
                    return res.status(500).json({ error: 'ไม่สามารถเพิ่ม other_expenses: ' + err.message });
                  }
                });
              }

              // Commit transaction เมื่อทุกขั้นตอนสำเร็จ
              db.run("COMMIT", (err) => {
                if (err) {
                  return res.status(500).json({ error: 'Commit transaction failed: ' + err.message });
                }
                res.status(200).json({ message: 'อัปเดตแผนสำเร็จ' });
              });
            });
          });
        });
      }
    );
  });
});
app.delete('/plans/:id', (req, res) => {
  const planId = req.params.id;

  db.serialize(() => {
    db.run(`DELETE FROM favorite_places WHERE plan_id = ?`, [planId]);
    db.run(`DELETE FROM places WHERE plan_id = ?`, [planId]);
    db.run(`DELETE FROM other_expenses WHERE plan_id = ?`, [planId]);
    db.run(`DELETE FROM plans WHERE id = ?`, [planId], function (err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true });
    });
  });
});


// --- เริ่มเซิร์ฟเวอร์ ---
app.listen(port, () => {
  console.log(`Server running at http://10.0.2.2:${port}`);
});
