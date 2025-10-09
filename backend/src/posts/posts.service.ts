import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { handlePrismaError } from '../common/prisma-error.handler';

@Injectable()
export class PostsService {
  constructor(private prisma: PrismaService) {}

  async create(createPostDto: CreatePostDto) {
    return this.prisma.post.create({
      data: createPostDto,
      include: {
        replies: {
          include: {
            replies: true,
          },
        },
      },
    });
  }

  async findAll() {
    return this.prisma.post.findMany({
      include: {
        replies: {
          include: {
            replies: true,
          },
          orderBy: {
            createdAt: 'asc',
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async findOne(id: string) {
    const post = await this.prisma.post.findUnique({
      where: { id },
      include: {
        replies: {
          include: {
            replies: true,
          },
          orderBy: {
            createdAt: 'asc',
          },
        },
        replyTo: true,
      },
    });

    if (!post) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }

    return post;
  }

  async update(id: string, updatePostDto: UpdatePostDto) {
    const existingPost = await this.prisma.post.findUnique({
      where: { id },
    });

    if (!existingPost) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }

    return this.prisma.post.update({
      where: { id },
      data: updatePostDto,
      include: {
        replies: {
          include: {
            replies: true,
          },
        },
      },
    });
  }

  async remove(id: string) {
    const existingPost = await this.prisma.post.findUnique({
      where: { id },
    });

    if (!existingPost) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }

    return this.prisma.post.delete({
      where: { id },
    });
  }

  async findReplies(id: string) {
    const post = await this.prisma.post.findUnique({
      where: { id },
    });

    if (!post) {
      throw new NotFoundException(`Post with ID ${id} not found`);
    }

    return this.prisma.post.findMany({
      where: { replyToId: id },
      include: {
        replies: {
          include: {
            replies: true,
          },
        },
      },
      orderBy: {
        createdAt: 'asc',
      },
    });
  }
}
