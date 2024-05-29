CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
	matricula VARCHAR(10),
    data_nascimento DATE
);

CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    carga_horaria INT
);

CREATE TABLE matricula (
    id SERIAL PRIMARY KEY,
    id_aluno INT REFERENCES alunos(id),
    id_curso INT REFERENCES cursos(id)
);

CREATE TYPE tipo_prova AS ENUM ('P1', 'P2', 'PF');

CREATE TABLE nota (
    id SERIAL PRIMARY KEY,
	tipo_prova tipo_prova,
    id_matricula int REFERENCES matricula(id),
    nota NUMERIC 
);