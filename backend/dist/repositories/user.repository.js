"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserRepository = void 0;
const prisma_1 = require("../config/prisma");
class UserRepository {
    async findByEmail(email) {
        return prisma_1.prisma.user.findUnique({ where: { email } });
    }
    async findById(id) {
        return prisma_1.prisma.user.findUnique({ where: { id } });
    }
    async create(input) {
        return prisma_1.prisma.user.create({
            data: {
                name: input.name,
                email: input.email,
                passwordHash: input.passwordHash,
            },
        });
    }
}
exports.UserRepository = UserRepository;
