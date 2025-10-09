import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable CORS for NextJS frontends
  app.enableCors({
    origin: [
      'http://localhost:3001', // NextJS live app
      'http://localhost:3002', // NextJS E05 app
      'http://localhost:3000', // Local development
    ],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
    }),
  );

  await app.listen(process.env.PORT ?? 3000);
  console.log('🚀 NestJS Posts API is running on http://localhost:3000');
}
void bootstrap();
