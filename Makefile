build:
	mkdir -p build
	raco exe -o build/creo src/main.rkt

clean:
	rm -rf build/creo
	rm -rf build
