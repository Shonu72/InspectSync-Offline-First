const authService = require('../services/auth.service');
const ApiError = require('../utils/ApiError');

const register = async (req, res, next) => {
  try {
    const user = await authService.register(req.body);
    const { password, ...userWithoutPassword } = user;
    res.status(201).json({
      success: true,
      data: userWithoutPassword
    });
  } catch (error) {
    next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      throw new ApiError(400, 'Email and password are required');
    }
    
    const { user, token } = await authService.login(email, password);
    const { password: _, ...userWithoutPassword } = user;
    
    res.json({
      success: true,
      data: {
        user: userWithoutPassword,
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

const me = async (req, res) => {
  res.json({
    success: true,
    data: req.user
  });
};

module.exports = {
  register,
  login,
  me
};
