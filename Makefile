SRC=src

all:
	make -C $(SRC) all

install:
	make -C $(SRC) install

clean:
	make -C $(SRC) clean

