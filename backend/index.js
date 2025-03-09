require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

if (!process.env.DB_HOST || !process.env.DB_USER || !process.env.DB_PASSWORD || !process.env.DB_NAME || !process.env.JWT_SECRET) {
  console.error('Faltan variables de entorno necesarias');
  process.exit(1);
}


// Configuración de MySQL
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Login
app.post('/api/login', async (req, res) => {
  try {

    console.log("entra aqui :) ");
    const { email, password } = req.body;
    const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    
    if (users.length === 0) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }
    
    const user = users[0];
    const validPassword = await bcrypt.compare(password, user.password);
    
    if (!validPassword) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }
    
    const token = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.json({ token });
    
  } catch (error) {
    res.status(500).json({ error: 'Error en el servidor' });
  }
});

// Obtener artículos
app.get('/api/articles', authenticateToken, async (req, res) => {
  try {
    const [articles] = await pool.query('SELECT * FROM articles');
    res.json(articles);
  } catch (error) {
    res.status(500).json({ error: 'Error cargando artículos' });
  }
});

// Middleware de autenticación JWT
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.sendStatus(401);
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

pool.getConnection()
  .then(connection => {
    console.log('Conexión a la base de datos establecida correctamente');
    connection.release(); // Libera la conexión después de la prueba
  })
  .catch(error => {
    console.error('Error al conectar con la base de datos:', error);
    process.exit(1); // Detiene el servidor si no se puede conectar
  });


// Iniciar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
});
