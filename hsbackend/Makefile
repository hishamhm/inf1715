
backend: backend.hs IrDados.hs IrLexico.hs IrSintatico.hs
	ghc -o backend backend.hs -XDeriveDataTypeable -XMultiParamTypeClasses -XFunctionalDependencies -XFlexibleInstances -XExistentialQuantification -XPolymorphicComponents -XCPP -XFlexibleContexts

clean:
	rm -f backend *.o *.hi core

