

exemplo: lex.yy.c
	gcc -o exemplo lex.yy.c

lex.yy.c: exemplo.l
	flex exemplo.l

clean:
	rm -f exemplo *.o lex.yy.c

test: exemplo
	@echo "Teste sem erros:"
	./exemplo < teste_ok.txt
	@echo "Teste com erros:"
	./exemplo < teste_erro.txt
