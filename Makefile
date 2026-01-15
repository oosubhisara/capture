NAME = capture
DISK_NAME = Capture
DISK_ID = 0
CC = 64tass
BIN_DIR = bin
SRC = src/$(NAME).asm
PRG_FILENAME = $(BIN_DIR)/$(NAME).prg
D64_FILENAME = $(BIN_DIR)/$(NAME).d64
LABELS = $(BIN_DIR)/labels.txt
LIST = $(BIN_DIR)/list.txt

all: $(PRG_FILENAME)

$(BIN_DIR):
	mkdir bin

$(PRG_FILENAME): $(BIN_DIR)
	$(CC) -a -C $(SRC) -o $(PRG_FILENAME) -l $(LABELS) -L $(LIST)

run:
	x64 $(PRG_FILENAME)

d64: $(PRG_FILENAME)
	c1541 -format "$(DISK_NAME), $(DISK_ID)" d64 $(D64_FILENAME) -write $(PRG_FILENAME) $(NAME)

clean:
	rm -f $(LABELS)
	rm -f $(LIST)
	rm -f snapshot.vsf

fclean: clean
	rm -f $(PRG_FILENAME)
	rm -f $(D64_FILENAME)
	rm -rf $(BIN_DIR)

.PHONY: all run d64 clean fclean

