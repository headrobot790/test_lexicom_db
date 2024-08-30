# Задание 2



## Содержание

- [Обзор](#обзор)
- [Цель задания](#цель_задания)
- [Настройка](#настройка)
- [Решение](#решение)
  - [1. Write Data (запись данных)](#1-write-data-запись-данных)
  - [2. Check Data (проверка данных)](#2-check-data-проверка-данных)
- [Сценарии использования](#сценарии-использования)
- [Комментарии и интерпретации](#комментарии-и-интерпретации)


## Обзор

Контейнер создает 2 таблицы в docker с индексами в колонках name

short_names размером 700 000 строк:

| id | name      | status |
|----|-----------|--------|
| 1  | nazvanie1 | 1      |
| 2  | nazvanie2 | 0      |
| 3  | nazvanie3 | 1      |

full_names размером 500 000 строк:

| id | name          | status |
|----|---------------|--------|
| 1  | nazvanie1.mp3 |        |
| 2  | nazvanie2.ogg |        |
| 3  | nazvanie3.wav |        |

с помощью sql скриптаinit.sql
## Цель_задания

-  В одной таблице хранятся имена файлов без расширения. В другой хранятся имена файлов с 
расширением. Одинаковых названий с разными расширениями быть не может, количество 
расширений не определено, помимо wavи mp3 может встретиться что угодно. 
Нам необходимо минимальным количеством запросов к СУБД перенести данные о статусе из таблицы 
short_names в таблицу full_names. 
- Необходимо понимать, что на выполнение запросов / время работы скрипта нельзя тратить больше 10 
минут. Лучшее время выполнения этого тестового задания в 2022 году - 45 секунд на SQL запросе

## Настройка

1. **Клонируйте репозиторий:**

   ```bash
   git clone https://github.com/headrobot790/test_lexicom_db.git

2. **Соберите и запустите сервисы с помощью Docker Compose:**
   ```bash
   docker-compose up --build

## Решение
1. **Обновляем значения в status на основе значений name, отбрасывая расширение**
```sql
UPDATE full_names f
SET status = s.status
FROM short_names s
WHERE substring(f.name from '^[^.]*') = s.name;
```

2. **Обновляет значения на основе промежуточных данных (CTE)**
```sql
WITH updated AS (
    SELECT f.name, s.status
    FROM short_names s
    JOIN full_names f
    ON s.name = substring(f.name from '^[^.]*')
)
UPDATE full_names f
SET status = u.status
FROM updated u
WHERE f.name = u.name;
```

Анализ показал, что первый запрос, без промежуточных данных выполнился быстрее

```text
"Update on full_names f  (cost=24311.00..44809.01 rows=0 width=0) (actual time=67036.149..67036.157 rows=0 loops=1)"
"  ->  Hash Join  (cost=24311.00..44809.01 rows=500000 width=16) (actual time=2533.503..11472.941 rows=500000 loops=1)"
"        Hash Cond: (""substring""(f.name, '^[^.]*'::text) = s.name)"
"        ->  Seq Scan on full_names f  (cost=0.00..8185.00 rows=500000 width=25) (actual time=0.061..1756.108 rows=500000 loops=1)"
"        ->  Hash  (cost=11459.00..11459.00 rows=700000 width=24) (actual time=2532.110..2532.112 rows=700000 loops=1)"
"              Buckets: 131072  Batches: 8  Memory Usage: 5875kB"
"              ->  Seq Scan on short_names s  (cost=0.00..11459.00 rows=700000 width=24) (actual time=0.106..1096.835 rows=700000 loops=1)"
"Planning Time: 1.428 ms"
"Execution Time: 67037.677 ms"
```

```text
"Update on full_names f  (cost=45840.00..81580.52 rows=0 width=0) (actual time=103564.276..103564.289 rows=0 loops=1)"
"  ->  Hash Join  (cost=45840.00..81580.52 rows=500000 width=22) (actual time=3063.879..19832.588 rows=500000 loops=1)"
"        Hash Cond: (""substring""(f_1.name, '^[^.]*'::text) = s.name)"
"        ->  Hash Join  (cost=21529.00..44956.51 rows=500000 width=31) (actual time=1494.901..5558.815 rows=500000 loops=1)"
"              Hash Cond: (f.name = f_1.name)"
"              ->  Seq Scan on full_names f  (cost=0.00..11861.00 rows=500000 width=25) (actual time=15.365..528.399 rows=500000 loops=1)"
"              ->  Hash  (cost=11861.00..11861.00 rows=500000 width=25) (actual time=1465.922..1465.924 rows=500000 loops=1)"
"                    Buckets: 131072  Batches: 8  Memory Usage: 4522kB"
"                    ->  Seq Scan on full_names f_1  (cost=0.00..11861.00 rows=500000 width=25) (actual time=0.039..401.484 rows=500000 loops=1)"
"        ->  Hash  (cost=11459.00..11459.00 rows=700000 width=24) (actual time=1568.071..1568.072 rows=700000 loops=1)"
"              Buckets: 131072  Batches: 8  Memory Usage: 5875kB"
"              ->  Seq Scan on short_names s  (cost=0.00..11459.00 rows=700000 width=24) (actual time=0.097..531.653 rows=700000 loops=1)"
"Planning Time: 1.486 ms"
"Execution Time: 103574.228 ms"
```
