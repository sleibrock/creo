CC = raco
FLAGS = --cs -v

TARGET = creo

ENTRY = src/main.rkt

BUILDDIR = build

all: $(TARGET)

$(TARGET):
	mkdir -p $(BUILDDIR)
	$(CC) exe $(FLAGS) -o $(BUILDDIR)/$(TARGET) $(ENTRY) 

test:
	raco test -x .

clean:
	rm -rf build/creo
	rm -rf build
