import { UserRepository } from "../repositories/user.repository";

export class AdminService {
  constructor(private readonly userRepository: UserRepository) {}

  async listUsers(input: {
    page: number;
    pageSize: number;
    search?: string;
    sortOrder: "asc" | "desc";
  }) {
    const result = await this.userRepository.listAll(input);

    return {
      items: result.items,
      total: result.total,
      page: input.page,
      pageSize: input.pageSize,
      totalPages: Math.max(1, Math.ceil(result.total / input.pageSize)),
    };
  }
}