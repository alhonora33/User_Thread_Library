#include "thread.h"
#include "queue.h"
#include <stdlib.h>
#include <stdio.h>
#include <ucontext.h>
#include <valgrind/valgrind.h>

#define STACK_SIZE 1024 * 1024
#define MAIN_THREAD_ID (void *)1

typedef enum thread_state
{
    READY,
    TERMINATED
} thread_state;

typedef struct thread_struct
{
    thread_state state;
    thread_t id;
    ucontext_t context;
    void *retval;
    int valgrind_stack_id;
    TAILQ_ENTRY(thread_struct)
    entries;
} thread_struct;

static thread_struct *current_thread;
static thread_t next_id = (void *)MAIN_THREAD_ID;
static TAILQ_HEAD(tailq_head, thread_struct) threads = TAILQ_HEAD_INITIALIZER(threads);

void print_log(const char *msg, thread_struct *thread)
{
    printf("%s: id=%p, state=%d\n", msg, thread->id, thread->state);
}

void print_tailq_log()
{
    thread_struct *thread = NULL;
    printf("TAILQ:  ");
    TAILQ_FOREACH(thread, &threads, entries)
    {
        printf("[id: %p , state: %d]  | ", thread->id, thread->state);
    }
    printf("\n");
}

__attribute__((constructor)) void init()
{
    thread_struct *main_thread = malloc(sizeof(thread_struct));
    main_thread->id = next_id++;
    main_thread->state = READY;
    main_thread->retval = 0;
    main_thread->context.uc_stack.ss_sp = NULL;
    getcontext(&main_thread->context);
    TAILQ_INSERT_TAIL(&threads, main_thread, entries);
    current_thread = main_thread;
}

__attribute__((destructor)) void destroy()
{
    thread_struct *thread = NULL;
    while (!TAILQ_EMPTY(&threads))
    {
        thread = TAILQ_FIRST(&threads);
        TAILQ_REMOVE(&threads, thread, entries);
        VALGRIND_STACK_DEREGISTER(thread->valgrind_stack_id);
        free(thread->context.uc_stack.ss_sp);
        free(thread);
    }
}

/* recuperer l'identifiant du thread courant.
 */
extern thread_t thread_self(void)
{
    return current_thread->id;
}

void thread_function_wrapper(void *(*function)(void *), void *arg)
{
    thread_exit(function(arg));
}

/* Parcourir la liste des threads et retourner le premier thread prêt à être exécuté.
 * Si aucun thread n'est prêt à être exécuté, retourner NULL.
 */
thread_struct *find_ready_thread()
{
    thread_struct *thread = NULL;
    TAILQ_FOREACH_REVERSE(thread, &threads, tailq_head, entries)
    {
        if (thread->state == READY)
        {
            return thread;
        }
    }
    return current_thread;
}

thread_struct *find_thread(thread_t id)
{
    thread_struct *thread = NULL;
    TAILQ_FOREACH(thread, &threads, entries)
    {
        if (thread->id == id)
        {
            return thread;
        }
    }
    return NULL;
}

/* creer un nouveau thread qui va exécuter la fonction func avec l'argument funcarg.
 * renvoie 0 en cas de succès, -1 en cas d'erreur.
 */
extern int thread_create(thread_t *newthread, void *(*func)(void *), void *funcarg)
{
    // Allocation de la structure du thread
    thread_struct *new_thread = malloc(sizeof(thread_struct));
    if (new_thread == NULL)
    {
        return -1;
    }

    // Initialisation de la structure du thread
    new_thread->id = next_id++;
    new_thread->state = READY;
    new_thread->retval = NULL;

    // Gestion du contexte et de la pile du thread créé
    new_thread->context.uc_stack.ss_sp = malloc(STACK_SIZE);
    new_thread->context.uc_stack.ss_size = STACK_SIZE;
    new_thread->valgrind_stack_id = VALGRIND_STACK_REGISTER(new_thread->context.uc_stack.ss_sp, new_thread->context.uc_stack.ss_sp + STACK_SIZE);
    new_thread->context.uc_link = NULL;
    getcontext(&new_thread->context); // recupere le contexte actuel

    if (new_thread->context.uc_stack.ss_sp == NULL)
    {
        free(new_thread);
        return -1;
    }
    makecontext(&new_thread->context, (void (*)(void))thread_function_wrapper, 2, func, funcarg);

    // Ajout du thread à la liste des threads
    TAILQ_INSERT_TAIL(&threads, new_thread, entries);
    *newthread = new_thread->id;
    //print_log("creation of a new thread", current_thread);
    //print_tailq_log();
    return 0;
}

/*
 * passer la main à un autre thread.
 */
extern int thread_yield(void)
{
    thread_struct *next_thread = find_ready_thread();
    if (next_thread->state == TERMINATED)
    {
        next_thread = find_thread(MAIN_THREAD_ID);
    }
    if (next_thread == current_thread)
    {   
        //print_log("yieling to the same", current_thread);
        return 0;
    }
    thread_struct *save_thread = current_thread;
    current_thread = next_thread;
    //print_log("yielding to another thread", current_thread);
    swapcontext(&save_thread->context, &current_thread->context);
    return 0;
}

/* attendre la fin d'exécution d'un thread.
 * la valeur renvoyée par le thread est placée dans *retval.
 * si retval est NULL, la valeur de retour est ignorée.
 */
extern int thread_join(thread_t thread, void **retval)
{
    thread_struct *thread_to_join = find_thread(thread);
    if (thread_to_join == NULL)
    {
        return -1;
    }
    while (thread_to_join->state != TERMINATED)
    {
        thread_yield();
    }
    if (retval != NULL)
    {
        *retval = thread_to_join->retval;
    }
    //print_log("joining a thread", thread_to_join);
    return 0;
}

/* terminer le thread courant en renvoyant la valeur de retour retval.
 * cette fonction ne retourne jamais.
 *
 * L'attribut noreturn aide le compilateur à optimiser le code de
 * l'application (élimination de code mort). Attention à ne pas mettre
 * cet attribut dans votre interface tant que votre thread_exit()
 * n'est pas correctement implémenté (il ne doit jamais retourner).
 */
extern void thread_exit(void *retval)
{
    current_thread->retval = retval;
    current_thread->state = TERMINATED;
    // le sortir de la file et le garder en mémoire et revoir yield
    //print_log("exiting a thread", current_thread);
    thread_yield();
    exit(0);
}

int thread_mutex_init(thread_mutex_t *mutex)
{
    if (mutex == NULL)
    {
        return 0;
    }
    return 0;
}
int thread_mutex_destroy(thread_mutex_t *mutex)
{
    if (mutex == NULL)
    {
        return 0;
    }
    return 0;
}
int thread_mutex_lock(thread_mutex_t *mutex)
{
    if (mutex == NULL)
    {
        return 0;
    }
    return 0;
}
int thread_mutex_unlock(thread_mutex_t *mutex)
{
    if (mutex == NULL)
    {
        return 0;
    }
    return 0;
}
