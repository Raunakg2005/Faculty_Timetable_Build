const mongoose = require('mongoose');
const User = require('./models/User');

mongoose.connect('mongodb://localhost:27017/teach_platform')
    .then(async () => {
        console.log('Connected to MongoDB');

        const excludeId = '69367865ce72869a069a23c9';
        const dbQuery = { _id: { $ne: excludeId } };

        console.log('Query:', JSON.stringify(dbQuery));

        const totalUsers = await User.countDocuments();
        console.log('Total users:', totalUsers);

        const users = await User.find(dbQuery).select('-password');
        console.log('Users found:', users.length);
        console.log('Users:', users.map(u => ({
            id: u._id.toString(),
            username: u.username,
            email: u.email
        })));

        process.exit(0);
    })
    .catch(err => {
        console.error('Error:', err);
        process.exit(1);
    });
