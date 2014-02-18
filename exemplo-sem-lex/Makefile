
all: exemplo exemplo_line

exemplo: lexer.c
	gcc -o exemplo lexer.c

exemplo_line: lexer_line.c
	gcc -o exemplo_line lexer_line.c

clean:
	rm -f exemplo exemplo_line *.o

test: exemplo exemplo_line
	@echo "Teste sem erros:"
	./exemplo < teste_ok.txt
	@echo "Teste com erros:"
	./exemplo < teste_erro.txt
	@echo "Teste sem erros (com numeros de linha):"
	./exemplo_line < teste_ok.txt
	@echo "Teste com erros (com numeros de linha):"
	./exemplo_line < teste_erro.txt

