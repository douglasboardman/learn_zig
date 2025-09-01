#include <stdio.h>
#include <unistd.h>

int main() {
    int resultado, pid, ppid;
    resultado = fork();
    if (resultado < 0)
        printf("Algo deu errado!!!\n");
    
    pid = getpid();
    
    if (resultado == 0) {
        ppid = getppid();
        printf("Eu sou o processo filho com PID %d e meu pai é %d\n", pid, ppid);
    }
    
    if (resultado > 0) {
        printf("Eu sou o processo pai com PID %d e meu filho é %d\n", pid, resultado);
        waitpid(resultado, NULL, 0);
    }
}