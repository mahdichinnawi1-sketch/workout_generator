const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ==================== DATABASE CONNECTION ====================
const db = mysql.createPool({
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: '',
    database: 'workout_app',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test connection
db.getConnection((err, connection) => {
    if (err) {
        console.error('❌ Database connection failed:', err.message);
        console.log('Make sure XAMPP MySQL is running!');
    } else {
        console.log('✅ Connected to your workout_app database!');
        connection.release();
    }
});

// ==================== INITIALIZE GEMINI AI ====================
let genAI;
const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey || apiKey === 'AIzaSyA-x-cbvSecJHBabM98-rq8R5YPcSYMHh0') {
    console.log('⚠️ GEMINI_API_KEY not set in .env file');
    console.log('   AI features will use fallback mode');
} else {
    try {
        genAI = new GoogleGenerativeAI(apiKey);
        console.log('✅ Google Gemini AI initialized');
    } catch (err) {
        console.log('❌ Failed to initialize Gemini AI:', err.message);
    }
}

// ==================== FALLBACK WORKOUT GENERATOR ====================
function generateFallbackWorkout(goal, injury, timeMinutes, equipment, experienceLevel) {
    const isInjury = injury && injury !== 'None' && injury !== '';
    
    let exerciseType = 'strength';
    if (goal.includes('Weight Loss')) exerciseType = 'cardio';
    if (goal.includes('Endurance')) exerciseType = 'endurance';
    
    const avoidHighImpact = isInjury && (injury.includes('Knee') || injury.includes('Ankle'));
    const avoidBackExercises = isInjury && injury.includes('Back');
    const avoidShoulderExercises = isInjury && injury.includes('Shoulder');
    
    const warmup = [
        { name: "Arm Circles", duration: "30 seconds", instructions: "Rotate arms forward and backward" },
        { name: "Leg Swings", duration: "30 seconds", instructions: "Swing legs forward and sideways" },
        { name: "Torso Twists", duration: "30 seconds", instructions: "Gently twist upper body" }
    ];
    
    let mainWorkout = [];
    
    if (exerciseType === 'cardio') {
        if (avoidHighImpact) {
            mainWorkout = [
                { name: "Seated Marching", sets: 3, reps: "30 seconds", rest: "15 seconds", instructions: "March in place while seated" },
                { name: "Standing Leg Raises", sets: 3, reps: "12 each leg", rest: "20 seconds", instructions: "Raise leg forward and to side" },
                { name: "Modified Jumping Jacks", sets: 3, reps: "15 reps", rest: "20 seconds", instructions: "Step side to side instead of jumping" }
            ];
        } else {
            mainWorkout = [
                { name: "Jumping Jacks", sets: 3, reps: "20 reps", rest: "20 seconds", instructions: "Full body cardio movement" },
                { name: "High Knees", sets: 3, reps: "30 seconds", rest: "20 seconds", instructions: "Drive knees up toward chest" },
                { name: "Mountain Climbers", sets: 3, reps: "30 seconds", rest: "20 seconds", instructions: "Alternate knees toward chest" }
            ];
        }
    } else if (exerciseType === 'strength') {
        if (avoidBackExercises) {
            mainWorkout = [
                { name: "Wall Push-ups", sets: 3, reps: "12-15 reps", rest: "30 seconds", instructions: "Keep back straight" },
                { name: "Glute Bridges", sets: 3, reps: "15 reps", rest: "30 seconds", instructions: "Squeeze glutes at top" },
                { name: "Bird-Dog", sets: 3, reps: "10 each side", rest: "20 seconds", instructions: "Extend opposite arm and leg" }
            ];
        } else if (avoidShoulderExercises) {
            mainWorkout = [
                { name: "Squats", sets: 3, reps: "12-15 reps", rest: "30 seconds", instructions: "Keep chest up" },
                { name: "Lunges", sets: 3, reps: "10 each leg", rest: "30 seconds", instructions: "Step forward and lower hips" },
                { name: "Plank", sets: 3, reps: "20-30 seconds", rest: "20 seconds", instructions: "Keep body in straight line" }
            ];
        } else {
            mainWorkout = [
                { name: "Push-ups", sets: 3, reps: "8-12 reps", rest: "30 seconds", instructions: "Keep core tight" },
                { name: "Squats", sets: 3, reps: "12-15 reps", rest: "30 seconds", instructions: "Keep chest up" },
                { name: "Plank", sets: 3, reps: "30 seconds", rest: "20 seconds", instructions: "Engage core throughout" }
            ];
        }
    } else {
        mainWorkout = [
            { name: "Bodyweight Squats", sets: 3, reps: "15 reps", rest: "20 seconds", instructions: "Slow and controlled" },
            { name: "Walking Lunges", sets: 3, reps: "10 each leg", rest: "20 seconds", instructions: "Step forward and lower" },
            { name: "Push-ups", sets: 3, reps: "10-12 reps", rest: "20 seconds", instructions: "Hands shoulder-width apart" }
        ];
    }
    
    const cooldown = [
        { name: "Quad Stretch", duration: "20 seconds each leg", instructions: "Pull heel toward glute" },
        { name: "Hamstring Stretch", duration: "20 seconds each leg", instructions: "Reach toward toes" },
        { name: "Upper Back Stretch", duration: "20 seconds", instructions: "Round back gently" }
    ];
    
    let notes = `• Stay hydrated throughout the workout\n• Listen to your body and rest if needed`;
    if (isInjury) {
        notes += `\n• ${injury} detected: Avoid movements that cause pain. Focus on form over intensity.`;
    }
    notes += `\n• ${goal}: Maintain consistency for best results`;
    
    return {
        warmup: warmup.slice(0, 3),
        mainWorkout: mainWorkout,
        cooldown: cooldown,
        notes: notes,
        totalTimeMinutes: timeMinutes
    };
}






// ==================== AUTH ENDPOINTS ====================

app.post('/api/auth/register', async (req, res) => {
    const { username, email, password, preferred_location, target_calories, weight_kg, height_cm, age, gender } = req.body;
    
    try {
        const [existing] = await db.promise().query(
            'SELECT id FROM users WHERE email = ? OR username = ?',
            [email, username]
        );
        
        if (existing.length > 0) {
            return res.status(400).json({ error: 'User already exists' });
        }
        
        const [result] = await db.promise().query(
            `INSERT INTO users (username, email, password_hash, preferred_location, target_calories, weight_kg, height_cm, age, gender) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [username, email, password, preferred_location || 'home', target_calories || 300, weight_kg || 70, height_cm || 170, age || 25, gender || 'male']
        );
        
        console.log(`✅ New user registered: ${username}`);
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

app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    
    try {
        const [users] = await db.promise().query(
            'SELECT id, username, email, preferred_location, target_calories FROM users WHERE email = ? AND password_hash = ?',
            [email, password]
        );
        
        if (users.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        const user = users[0];
        console.log(`✅ User logged in: ${user.username}`);
        
        res.json({
            message: 'Login successful',
            token: 'token_' + user.id,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                preferred_location: user.preferred_location,
                target_calories: user.target_calories
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

app.get('/api/auth/profile/:userId', async (req, res) => {
    const userId = req.params.userId;
    
    try {
        const [users] = await db.promise().query(
            'SELECT id, username, email, preferred_location, target_calories, weight_kg, height_cm, age, gender, created_at FROM users WHERE id = ?',
            [userId]
        );
        
        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        res.json(users[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

app.put('/api/auth/profile/:userId', async (req, res) => {
    const userId = req.params.userId;
    const { preferred_location, target_calories, weight_kg, height_cm, age, gender } = req.body;
    
    try {
        await db.promise().query(
            `UPDATE users SET 
                preferred_location = COALESCE(?, preferred_location),
                target_calories = COALESCE(?, target_calories),
                weight_kg = COALESCE(?, weight_kg),
                height_cm = COALESCE(?, height_cm),
                age = COALESCE(?, age),
                gender = COALESCE(?, gender)
             WHERE id = ?`,
            [preferred_location, target_calories, weight_kg, height_cm, age, gender, userId]
        );
        
        res.json({ message: 'Profile updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});






// ==================== WORKOUT ENDPOINTS ====================

app.post('/api/workouts/save', async (req, res) => {
    const { user_id, duration_minutes, total_calories, goal_type, location } = req.body;
    
    try {
        const [result] = await db.promise().query(
            `INSERT INTO workout_sessions (user_id, workout_date, duration_minutes, total_calories, goal_type, location) 
             VALUES (?, CURDATE(), ?, ?, ?, ?)`,
            [user_id, duration_minutes, total_calories, goal_type, location]
        );
        
        console.log(`✅ Workout saved for user ${user_id}`);
        res.status(201).json({ message: 'Workout saved successfully', session_id: result.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

app.get('/api/workouts/history/:userId', async (req, res) => {
    const userId = req.params.userId;
    
    try {
        const [workouts] = await db.promise().query(
            `SELECT id, workout_date, duration_minutes, total_calories, goal_type, location 
             FROM workout_sessions 
             WHERE user_id = ? 
             ORDER BY workout_date DESC 
             LIMIT 20`,
            [userId]
        );
        
        res.json(workouts);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

app.get('/api/workouts/stats/:userId', async (req, res) => {
    const userId = req.params.userId;
    
    try {
        const [total] = await db.promise().query(
            'SELECT COUNT(*) as total, COALESCE(SUM(total_calories),0) as total_calories, COALESCE(SUM(duration_minutes),0) as total_minutes FROM workout_sessions WHERE user_id = ?',
            [userId]
        );
        
        const [weekly] = await db.promise().query(
            `SELECT COUNT(*) as workouts_this_week 
             FROM workout_sessions 
             WHERE user_id = ? AND workout_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)`,
            [userId]
        );
        
        res.json({
            total_workouts: total[0]?.total || 0,
            total_calories: total[0]?.total_calories || 0,
            total_minutes: total[0]?.total_minutes || 0,
            workouts_this_week: weekly[0]?.workouts_this_week || 0
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});






// ==================== AI RECOMMENDATION ENDPOINT ====================

app.post('/api/ai/recommend-workout', async (req, res) => {
    const {
        goal,
        injury,
        timeMinutes,
        equipment,
        experienceLevel
    } = req.body;
    
    console.log('AI Request received:', { goal, injury, timeMinutes, equipment, experienceLevel });
    
    // Fallback workout generator (in case AI fails)
    const generateFallbackWorkout = (goal, injury, timeMinutes, equipment, experienceLevel) => {
        const isInjury = injury && injury !== 'None' && injury !== '';
        
        let exerciseType = 'strength';
        if (goal && goal.includes('Weight Loss')) exerciseType = 'cardio';
        if (goal && goal.includes('Endurance')) exerciseType = 'endurance';
        
        const avoidHighImpact = isInjury && (injury.includes('Knee') || injury.includes('Ankle'));
        
        const warmup = [
            { name: "Arm Circles", duration: "30 seconds", instructions: "Rotate arms forward and backward" },
            { name: "Leg Swings", duration: "30 seconds", instructions: "Swing legs forward and sideways" },
            { name: "Torso Twists", duration: "30 seconds", instructions: "Gently twist upper body" }
        ];
        
        let mainWorkout = [];
        
        if (exerciseType === 'cardio') {
            if (avoidHighImpact) {
                mainWorkout = [
                    { name: "Seated Marching", sets: 3, reps: "30 seconds", rest: "15 seconds", instructions: "March in place while seated" },
                    { name: "Standing Leg Raises", sets: 3, reps: "12 each leg", rest: "20 seconds", instructions: "Raise leg forward and to side" },
                    { name: "Modified Jumping Jacks", sets: 3, reps: "15 reps", rest: "20 seconds", instructions: "Step side to side instead of jumping" }
                ];
            } else {
                mainWorkout = [
                    { name: "Jumping Jacks", sets: 3, reps: "20 reps", rest: "20 seconds", instructions: "Full body cardio movement" },
                    { name: "High Knees", sets: 3, reps: "30 seconds", rest: "20 seconds", instructions: "Drive knees up toward chest" },
                    { name: "Mountain Climbers", sets: 3, reps: "30 seconds", rest: "20 seconds", instructions: "Alternate knees toward chest" }
                ];
            }
        } else if (exerciseType === 'strength') {
            mainWorkout = [
                { name: "Push-ups", sets: 3, reps: "8-12 reps", rest: "30 seconds", instructions: "Keep core tight" },
                { name: "Squats", sets: 3, reps: "12-15 reps", rest: "30 seconds", instructions: "Keep chest up" },
                { name: "Plank", sets: 3, reps: "30 seconds", rest: "20 seconds", instructions: "Engage core throughout" }
            ];
        } else {
            mainWorkout = [
                { name: "Bodyweight Squats", sets: 3, reps: "15 reps", rest: "20 seconds", instructions: "Slow and controlled" },
                { name: "Walking Lunges", sets: 3, reps: "10 each leg", rest: "20 seconds", instructions: "Step forward and lower" },
                { name: "Push-ups", sets: 3, reps: "10-12 reps", rest: "20 seconds", instructions: "Hands shoulder-width apart" }
            ];
        }
        
        const cooldown = [
            { name: "Quad Stretch", duration: "20 seconds each leg", instructions: "Pull heel toward glute" },
            { name: "Hamstring Stretch", duration: "20 seconds each leg", instructions: "Reach toward toes" },
            { name: "Upper Back Stretch", duration: "20 seconds", instructions: "Round back gently" }
        ];
        
        let notes = `• Stay hydrated throughout the workout\n• Listen to your body and rest if needed`;
        if (isInjury) {
            notes += `\n• ${injury}: Avoid movements that cause pain. Focus on form over intensity.`;
        }
        notes += `\n• ${goal || 'Fitness'} goal: Maintain consistency for best results`;
        
        return {
            warmup: warmup,
            mainWorkout: mainWorkout,
            cooldown: cooldown,
            notes: notes,
            totalTimeMinutes: timeMinutes || 30
        };
    };
    
    try {
        // Check if Gemini AI is available
        if (!genAI) {
            console.log('Using fallback workout (AI not initialized)');
            const fallbackWorkout = generateFallbackWorkout(goal, injury, timeMinutes, equipment, experienceLevel);
            return res.json({
                success: true,
                workout: fallbackWorkout,
                message: "Workout generated using smart template"
            });
        }
        
        // Build prompt for Gemini
        const prompt = `Generate a workout plan. User wants: ${goal || 'fitness'}. Time: ${timeMinutes || 30} minutes. Equipment: ${equipment || 'bodyweight'}. Experience: ${experienceLevel || 'beginner'}. ${injury && injury !== 'None' ? `User has ${injury}. Avoid exercises that worsen this.` : ''}
        
Return ONLY valid JSON, no other text:
{
    "warmup": [{"name": "exercise", "duration": "30s", "instructions": "how to do it"}],
    "mainWorkout": [{"name": "exercise", "sets": 3, "reps": "10-12", "rest": "30s", "instructions": "how to do it"}],
    "cooldown": [{"name": "stretch", "duration": "20s", "instructions": "how to stretch"}],
    "notes": "safety tips",
    "totalTimeMinutes": ${timeMinutes || 30}
}`;

        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
        const result = await model.generateContent(prompt);
        const text = result.response.text();
        
        let workoutPlan;
        try {
            const jsonMatch = text.match(/\{[\s\S]*\}/);
            workoutPlan = jsonMatch ? JSON.parse(jsonMatch[0]) : generateFallbackWorkout(goal, injury, timeMinutes, equipment, experienceLevel);
        } catch (e) {
            workoutPlan = generateFallbackWorkout(goal, injury, timeMinutes, equipment, experienceLevel);
        }
        
        res.json({
            success: true,
            workout: workoutPlan,
            message: "AI-generated workout"
        });
        
    } catch (error) {
        console.error('AI Error:', error.message);
        const fallbackWorkout = generateFallbackWorkout(goal, injury, timeMinutes, equipment, experienceLevel);
        res.json({
            success: true,
            workout: fallbackWorkout,
            message: "AI unavailable, using smart template"
        });
    }
});





// ==================== NUTRITION ENDPOINTS ====================

// Get all foods (with search)
app.get('/api/nutrition/foods', async (req, res) => {
    const { search, category } = req.query;
    
    try {
        let query = 'SELECT * FROM foods WHERE 1=1';
        let params = [];
        
        if (search) {
            query += ' AND name LIKE ?';
            params.push(`%${search}%`);
        }
        
        if (category) {
            query += ' AND category = ?';
            params.push(category);
        }
        
        query += ' ORDER BY name LIMIT 50';
        
        const [foods] = await db.promise().query(query, params);
        res.json(foods);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Get single food by ID
app.get('/api/nutrition/foods/:id', async (req, res) => {
    const foodId = req.params.id;
    
    try {
        const [foods] = await db.promise().query(
            'SELECT * FROM foods WHERE id = ?',
            [foodId]
        );
        
        if (foods.length === 0) {
            return res.status(404).json({ error: 'Food not found' });
        }
        
        res.json(foods[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Get meal suggestions
app.get('/api/nutrition/suggestions/:goal', (req, res) => {
    const goal = req.params.goal;
    
    let mealSuggestions = {};
    
    if (goal.includes('Weight Loss')) {
        mealSuggestions = {
            breakfast: ['Greek Yogurt with Berries', 'Oatmeal with Protein Powder', 'Spinach Omelette'],
            lunch: ['Grilled Chicken Salad', 'Quinoa Bowl', 'Tuna Wrap'],
            dinner: ['Baked Salmon with Asparagus', 'Turkey Meatballs with Zucchini Noodles', 'Tofu Stir-fry'],
            snacks: ['Apple with Almond Butter', 'Protein Shake', 'Handful of Nuts']
        };
    } else if (goal.includes('Muscle Building')) {
        mealSuggestions = {
            breakfast: ['Protein Pancakes', 'Eggs with Avocado Toast', 'Oatmeal with Whey Protein'],
            lunch: ['Chicken Breast with Rice', 'Lean Beef Bowl', 'Salmon with Sweet Potato'],
            dinner: ['Steak with Quinoa', 'Turkey Chili', 'Shrimp Pasta'],
            snacks: ['Protein Shake + Banana', 'Chocolate Milk', 'Greek Yogurt with Honey']
        };
    } else {
        mealSuggestions = {
            breakfast: ['Whole Grain Toast with Eggs', 'Smoothie Bowl', 'Oatmeal with Fruits'],
            lunch: ['Turkey Sandwich', 'Chicken Wrap', 'Veggie Bowl'],
            dinner: ['Grilled Fish with Rice', 'Chicken Stir-fry', 'Pasta with Lean Meat'],
            snacks: ['Fruit', 'Yogurt', 'Protein Bar']
        };
    }
    
    res.json(mealSuggestions);
});

// Get user's nutrition goals
app.get('/api/nutrition/goals/:userId', async (req, res) => {
    const userId = req.params.userId;
    
    try {
        const [users] = await db.promise().query(
            'SELECT weight_kg, height_cm, age, gender FROM users WHERE id = ?',
            [userId]
        );
        
        if (users.length === 0) {
            return res.json({
                daily_calorie_target: 2000,
                daily_protein_target: 150,
                daily_carbs_target: 250,
                daily_fat_target: 55
            });
        }
        
        const user = users[0];
        let bmr;
        if (user.gender === 'male') {
            bmr = 10 * (user.weight_kg || 70) + 6.25 * (user.height_cm || 170) - 5 * (user.age || 25) + 5;
        } else {
            bmr = 10 * (user.weight_kg || 60) + 6.25 * (user.height_cm || 160) - 5 * (user.age || 25) - 161;
        }
        
        const tdee = bmr * 1.55;
        const targetCalories = Math.round(tdee);
        const targetProtein = Math.round((targetCalories * 0.3) / 4);
        const targetCarbs = Math.round((targetCalories * 0.4) / 4);
        const targetFat = Math.round((targetCalories * 0.3) / 9);
        
        res.json({
            daily_calorie_target: targetCalories,
            daily_protein_target: targetProtein,
            daily_carbs_target: targetCarbs,
            daily_fat_target: targetFat
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Update user's nutrition goals
app.put('/api/nutrition/goals/:userId', async (req, res) => {
    const userId = req.params.userId;
    const { daily_calorie_target, daily_protein_target, daily_carbs_target, daily_fat_target } = req.body;
    
    try {
        await db.promise().query(
            `INSERT INTO user_nutrition_goals (user_id, daily_calorie_target, daily_protein_target, daily_carbs_target, daily_fat_target)
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE
             daily_calorie_target = VALUES(daily_calorie_target),
             daily_protein_target = VALUES(daily_protein_target),
             daily_carbs_target = VALUES(daily_carbs_target),
             daily_fat_target = VALUES(daily_fat_target)`,
            [userId, daily_calorie_target, daily_protein_target, daily_carbs_target, daily_fat_target]
        );
        
        res.json({ message: 'Nutrition goals updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Log a meal
app.post('/api/nutrition/log', async (req, res) => {
    const { user_id, food_id, serving_size_g, meal_type, log_date } = req.body;
    
    try {
        const [result] = await db.promise().query(
            `INSERT INTO nutrition_logs (user_id, food_id, serving_size_g, meal_type, log_date) 
             VALUES (?, ?, ?, ?, ?)`,
            [user_id, food_id, serving_size_g || 100, meal_type, log_date || new Date().toISOString().split('T')[0]]
        );
        
        res.status(201).json({ message: 'Meal logged successfully', log_id: result.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Get user's nutrition logs
app.get('/api/nutrition/logs/:userId', async (req, res) => {
    const userId = req.params.userId;
    const { date } = req.query;
    const logDate = date || new Date().toISOString().split('T')[0];
    
    try {
        const [logs] = await db.promise().query(
            `SELECT nl.*, f.name as food_name, f.calories, f.protein, f.carbs, f.fat 
             FROM nutrition_logs nl
             JOIN foods f ON nl.food_id = f.id
             WHERE nl.user_id = ? AND nl.log_date = ?
             ORDER BY nl.meal_type, nl.created_at`,
            [userId, logDate]
        );
        
        let totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
        logs.forEach(log => {
            const ratio = log.serving_size_g / 100;
            totalCalories += (log.calories || 0) * ratio;
            totalProtein += (log.protein || 0) * ratio;
            totalCarbs += (log.carbs || 0) * ratio;
            totalFat += (log.fat || 0) * ratio;
        });
        
        res.json({
            logs: logs,
            totals: {
                calories: Math.round(totalCalories),
                protein: Math.round(totalProtein),
                carbs: Math.round(totalCarbs),
                fat: Math.round(totalFat)
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Delete a nutrition log
app.delete('/api/nutrition/logs/:logId', async (req, res) => {
    const logId = req.params.logId;
    
    try {
        await db.promise().query('DELETE FROM nutrition_logs WHERE id = ?', [logId]);
        res.json({ message: 'Meal log deleted successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});





// ==================== HEALTH CHECK ====================

app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', message: 'Workout API is running!' });
});

// ==================== START SERVER ====================

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🤖 AI endpoint: http://localhost:${PORT}/api/ai/recommend-workout`);
});