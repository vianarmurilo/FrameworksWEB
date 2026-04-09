"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const zod_1 = require("zod");
const env_1 = require("../config/env");
const app_error_1 = require("../utils/app-error");
const registerSchema = zod_1.z.object({
    name: zod_1.z.string().min(2).max(120),
    email: zod_1.z.email().toLowerCase(),
    password: zod_1.z.string().min(8).max(64),
});
const loginSchema = zod_1.z.object({
    email: zod_1.z.email().toLowerCase(),
    password: zod_1.z.string().min(8).max(64),
});
class AuthService {
    constructor(userRepository) {
        this.userRepository = userRepository;
    }
    async register(rawInput) {
        const input = registerSchema.parse(rawInput);
        const existingUser = await this.userRepository.findByEmail(input.email);
        if (existingUser) {
            throw new app_error_1.AppError("E-mail ja cadastrado", 409);
        }
        const passwordHash = await bcryptjs_1.default.hash(input.password, 10);
        const user = await this.userRepository.create({
            name: input.name,
            email: input.email,
            passwordHash,
        });
        const token = this.generateToken(user.id, user.email);
        return {
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                currency: user.currency,
            },
        };
    }
    async login(rawInput) {
        const input = loginSchema.parse(rawInput);
        const user = await this.userRepository.findByEmail(input.email);
        if (!user) {
            throw new app_error_1.AppError("Credenciais invalidas", 401);
        }
        const passwordMatch = await bcryptjs_1.default.compare(input.password, user.passwordHash);
        if (!passwordMatch) {
            throw new app_error_1.AppError("Credenciais invalidas", 401);
        }
        const token = this.generateToken(user.id, user.email);
        return {
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                currency: user.currency,
            },
        };
    }
    generateToken(userId, email) {
        const options = {
            subject: userId,
            expiresIn: env_1.env.JWT_EXPIRES_IN,
        };
        return jsonwebtoken_1.default.sign({ email }, env_1.env.JWT_SECRET, options);
    }
}
exports.AuthService = AuthService;
