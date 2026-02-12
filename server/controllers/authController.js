const User = require('../models/User');

exports.register = async (req, res) => {
    try {
        console.log('Registration request received:', req.body);
        const { username, email, password } = req.body;
        // Basic validation
        if (!username || !email || !password) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        // Check if user exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: 'User already exists' });
        }

        const newUser = new User({ username, email, password });
        await newUser.save();

        res.status(201).json({ message: 'User registered successfully', userId: newUser._id });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.login = async (req, res) => {
    try {
        console.log('=== LOGIN REQUEST ===');
        console.log('Request body:', req.body);
        const { email, password } = req.body;
        console.log('Email:', email);
        console.log('Password:', password ? '***' : 'MISSING');

        // Find user
        console.log('Searching for user with email:', email);
        const user = await User.findOne({ email });
        console.log('User found:', user ? `Yes (${user.username})` : 'No');

        if (!user) {
            console.log('Login failed: User not found');
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Check password (simple comparison for now)
        console.log('Checking password...');
        if (user.password !== password) {
            console.log('Login failed: Password mismatch');
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        console.log('Login successful for user:', user.username);
        const response = { message: 'Login successful', user: { id: user._id, username: user.username, email: user.email } };
        console.log('Sending response:', response);
        res.json(response);
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.searchUsers = async (req, res) => {
    try {
        const { query, excludeId } = req.query;
        console.log('=== SEARCH USERS ===');
        console.log('Search params:', { query, excludeId });
        let dbQuery = {};

        if (query) {
            dbQuery.$or = [
                { username: { $regex: query, $options: 'i' } },
                { email: { $regex: query, $options: 'i' } }
            ];
        }

        if (excludeId) {
            dbQuery._id = { $ne: excludeId };
        }

        console.log('DB Query:', JSON.stringify(dbQuery));

        // First, let's see total users in database
        const totalUsers = await User.countDocuments();
        console.log('Total users in database:', totalUsers);

        const users = await User.find(dbQuery).select('-password');
        console.log('Users found:', users.length);
        console.log('User details:', users.map(u => ({ id: u._id, username: u.username, email: u.email })));

        res.json(users);
    } catch (error) {
        console.error('Search users error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
