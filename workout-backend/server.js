const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database connection - Online FreeSQLDatabase
const db = mysql.createPool({
    host: 'sql12.freesqldatabase.com',
    port: 3306,
    user: 'sql12827116',
    password: 'sCmqkCPFIg',
    database: 'sql12827116',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test connection
db.getConnection((err, connection) => {
    if (err) {
        console.error('Database connection failed:', err.message);
    } else {
        console.log('Connected to online database on FreeSQLDatabase!');
        connection.release();
    }
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', message: 'Workout API is running with online MySQL!' });
});

// Get all foods
app.get('/api/nutrition/foods', async (req, res) => {
    try {
        const [foods] = await db.promise().query('SELECT * FROM foods LIMIT 50');
        res.json(foods);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Login endpoint
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    
    try {
        const [users] = await db.promise().query(
            'SELECT id, username, email FROM users WHERE email = ? AND password_hash = ?',
            [email, password]
        );
        
        if (users.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        res.json({
            message: 'Login successful',
            token: 'token_' + users[0].id,
            user: users[0]
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Register endpoint
app.post('/api/auth/register', async (req, res) => {
    const { username, email, password } = req.body;
    
    try {
        const [result] = await db.promise().query(
            'INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)',
            [username, email, password]
        );
        
        res.status(201).json({
            message: 'User registered successfully',
            token: 'token_' + result.insertId,
            user: { id: result.insertId, username, email }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});