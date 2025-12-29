use std::sync::{Arc, Mutex, Condvar};
use std::thread;
use std::collections::VecDeque;

type Task = Box<dyn FnOnce() + Send + 'static>;

struct ThreadPool {
    workers: Vec<Worker>,
    task_queue: Arc<(Mutex<VecDeque<Task>>, Condvar)>,
}

impl ThreadPool {
    fn new(size: usize) -> Self {
        assert!(size > 0);

        let task_queue = Arc::new((Mutex::new(VecDeque::new()), Condvar::new()));
        let mut workers = Vec::with_capacity(size);

        for id in 0..size {
            workers.push(Worker::new(id, Arc::clone(&task_queue)));
        }

        ThreadPool { workers, task_queue }
    }

    fn submit<F>(&self, task: F)
    where
        F: FnOnce() + Send + 'static,
    {
        let (lock, cvar) = &*self.task_queue;
        let mut queue = lock.lock().unwrap();
        
        println!("[Main] Добавляем задачу в очередь. Очередь: {} задач", queue.len() + 1);
        queue.push_back(Box::new(task));
        cvar.notify_one();
    }
}

struct Worker {
    id: usize,
    thread: Option<thread::JoinHandle<()>>,
}

impl Worker {
    fn new(id: usize, task_queue: Arc<(Mutex<VecDeque<Task>>, Condvar)>) -> Self {
        let thread = thread::spawn(move || {
            let (lock, cvar) = &*task_queue;
            
            loop {
                let mut queue = lock.lock().unwrap();
                
                while queue.is_empty() {
                    println!("[Worker {}] Ожидаю задачу...", id);
                    queue = cvar.wait(queue).unwrap();
                }
                
                let task = queue.pop_front().unwrap();
                let remaining = queue.len();
                println!("[Worker {}] Начинаю выполнение задачи. Осталось в очереди: {}", id, remaining);
                
                drop(queue);
                
                task();
                println!("[Worker {}] Задача завершена", id);
            }
        });

        Worker { id, thread: Some(thread) }
    }
}

impl Drop for ThreadPool {
    fn drop(&mut self) {
        for worker in &mut self.workers {
            if let Some(thread) = worker.thread.take() {
                thread.join().unwrap();
            }
        }
        println!("Пул потоков остановлен");
    }
}

fn main() {
    let pool = ThreadPool::new(3);

    for i in 0..10 {
        pool.submit(move || {
            println!("[Task {}] Выполняется...", i);
            thread::sleep(std::time::Duration::from_millis(500));
            println!("[Task {}] Готово!", i);
        });
    }

    thread::sleep(std::time::Duration::from_secs(3));
    println!("Все задачи выполнены");
}