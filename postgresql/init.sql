-- Script de inicialização do PostgreSQL - Banco de teste
-- Criar banco de dados de teste
CREATE DATABASE teste;

-- Criar usuário de teste
CREATE USER testuser WITH PASSWORD 'test123';

-- Conceder privilégios ao usuário no banco de teste
GRANT ALL PRIVILEGES ON DATABASE teste TO testuser;

-- Conceder privilégios de criação de esquemas
ALTER USER testuser CREATEDB;
