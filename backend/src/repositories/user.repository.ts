import { prisma } from "../config/prisma";

interface ListAllOptions {
  page: number;
  pageSize: number;
  search?: string;
  sortOrder: "asc" | "desc";
}

export class UserRepository {
  async findByEmail(email: string) {
    return prisma.user.findUnique({ where: { email } });
  }

  async findById(id: string) {
    return prisma.user.findUnique({ where: { id } });
  }

  async create(input: {
    name: string;
    email: string;
    passwordHash: string;
    role?: "USER" | "ADMIN";
  }) {
    return prisma.user.create({
      data: {
        name: input.name,
        email: input.email,
        passwordHash: input.passwordHash,
        role: input.role,
      },
    });
  }

  async listAll(options: ListAllOptions) {
    const where = options.search
      ? {
          OR: [
            { name: { contains: options.search, mode: "insensitive" as const } },
            { email: { contains: options.search, mode: "insensitive" as const } },
          ],
        }
      : undefined;

    const [items, total] = await Promise.all([
      prisma.user.findMany({
        where,
        orderBy: { createdAt: options.sortOrder },
        skip: (options.page - 1) * options.pageSize,
        take: options.pageSize,
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
          currency: true,
          createdAt: true,
        },
      }),
      prisma.user.count({ where }),
    ]);

    return { items, total };
  }
}
