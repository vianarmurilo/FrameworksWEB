import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { z } from "zod";
import { env } from "../config/env";
import { UserRepository } from "../repositories/user.repository";
import { AppError } from "../utils/app-error";

const registerSchema = z.object({
  name: z.string().min(2).max(120),
  email: z.email().toLowerCase(),
  password: z.string().min(8).max(64),
});

const loginSchema = z.object({
  email: z.email().toLowerCase(),
  password: z.string().min(8).max(64),
});

export class AuthService {
  constructor(private readonly userRepository: UserRepository) {}

  private isAdminEmail(email: string): boolean {
    const allowed = env.ADMIN_EMAILS.split(",")
      .map((item) => item.trim().toLowerCase())
      .filter((item) => item.length > 0);

    return allowed.includes(email.toLowerCase());
  }

  async register(rawInput: unknown) {
    const input = registerSchema.parse(rawInput);

    const existingUser = await this.userRepository.findByEmail(input.email);
    if (existingUser) {
      throw new AppError("E-mail ja cadastrado", 409);
    }

    const passwordHash = await bcrypt.hash(input.password, 10);

    const user = await this.userRepository.create({
      name: input.name,
      email: input.email,
      passwordHash,
      role: this.isAdminEmail(input.email) ? "ADMIN" : "USER",
    });

    const token = this.generateToken(user.id, user.email, user.role);

    return {
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        currency: user.currency,
        role: user.role,
      },
    };
  }

  async login(rawInput: unknown) {
    const input = loginSchema.parse(rawInput);

    const user = await this.userRepository.findByEmail(input.email);
    if (!user) {
      throw new AppError("Credenciais invalidas", 401);
    }

    const passwordMatch = await bcrypt.compare(input.password, user.passwordHash);
    if (!passwordMatch) {
      throw new AppError("Credenciais invalidas", 401);
    }

    const token = this.generateToken(user.id, user.email, user.role);

    return {
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        currency: user.currency,
        role: user.role,
      },
    };
  }

  private generateToken(userId: string, email: string, role: "USER" | "ADMIN" = "USER"): string {
    const options: jwt.SignOptions = {
      subject: userId,
      expiresIn: env.JWT_EXPIRES_IN as jwt.SignOptions["expiresIn"],
    };

    return jwt.sign({ email, role }, env.JWT_SECRET, options);
  }
}
