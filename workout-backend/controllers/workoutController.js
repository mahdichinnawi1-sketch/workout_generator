const db = require('../models/db');

exports.saveWorkout = async (req, res) => {
    const { user_id, duration_minutes, total_calories, goal_type, location, exercises } = req.body;
    
    try {
        // Insert workout session
        const [session] = await db.query(
            `INSERT INTO workout_sessions (user_id, workout_date, duration_minutes, total_calories, goal_type, location) 
             VALUES (?, CURDATE(), ?, ?, ?, ?)`,
            [user_id, duration_minutes, total_calories, goal_type, location]
        );
        
        // Insert workout details
        for (const exercise of exercises) {
            await db.query(
                `INSERT INTO workout_details (workout_session_id, exercise_id, sets_completed, reps_completed, time_spent_seconds) 
                 VALUES (?, ?, ?, ?, ?)`,
                [session.insertId, exercise.exercise_id, exercise.sets, exercise.reps, exercise.time_spent]
            );
        }
        
        res.status(201).json({ message: 'Workout saved successfully', session_id: session.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
};

exports.getWorkoutHistory = async (req, res) => {
    const { userId } = req.params;
    
    try {
        const [workouts] = await db.query(
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
        res.status(500).json({ error: 'Server error' });
    }
};

exports.getWorkoutStats = async (req, res) => {
    const { userId } = req.params;
    
    try {
        // Total workouts count
        const [total] = await db.query(
            'SELECT COUNT(*) as total, SUM(total_calories) as total_calories, SUM(duration_minutes) as total_minutes FROM workout_sessions WHERE user_id = ?',
            [userId]
        );
        
        // Weekly progress
        const [weekly] = await db.query(
            `SELECT COUNT(*) as workouts_this_week 
             FROM workout_sessions 
             WHERE user_id = ? AND workout_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)`,
            [userId]
        );
        
        res.json({
            total_workouts: total[0].total || 0,
            total_calories: total[0].total_calories || 0,
            total_minutes: total[0].total_minutes || 0,
            workouts_this_week: weekly[0].workouts_this_week || 0
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
};

exports.deleteWorkout = async (req, res) => {
    const { id } = req.params;
    
    try {
        await db.query('DELETE FROM workout_sessions WHERE id = ?', [id]);
        res.json({ message: 'Workout deleted successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
};