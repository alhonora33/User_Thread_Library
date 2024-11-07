# Compilateur et options
CC=gcc
CFLAGS=-Wall -Wextra -std=c99 -g

# Répertoires
SRC_DIR=src
TEST_DIR=tst
BUILD_DIR=build
TEST_BUILD_DIR=$(BUILD_DIR)/tst
LIB_BUILD_DIR=$(BUILD_DIR)/lib
INSTALL_DIR=install
INSTALL_BIN_DIR=$(INSTALL_DIR)/bin
INSTALL_LIB_DIR=$(INSTALL_DIR)/lib

# Fichiers
LIB_SRC=$(wildcard $(SRC_DIR)/*.c)
LIB_OBJ=$(LIB_SRC:$(SRC_DIR)/%.c=$(LIB_BUILD_DIR)/%.o)
LIB=$(LIB_BUILD_DIR)/libthread.so


TEST_SRC=$(wildcard $(TEST_DIR)/*.c)
TEST_OBJ=$(TEST_SRC:$(TEST_DIR)/%.c=$(TEST_BUILD_DIR)/%.o)

PTHREAD_TEST_OBJ=$(TEST_SRC:$(TEST_DIR)/%.c=$(TEST_BUILD_DIR)/%-pthread.o)
TEST=$(TEST_OBJ:$(TEST_BUILD_DIR)/%.o=$(TEST_BUILD_DIR)/%)
PTHREAD_TEST=$(PTHREAD_TEST_OBJ:$(TEST_BUILD_DIR)/%.o=$(TEST_BUILD_DIR)/%)

# Règles
all: lib tests

# Créer les répertoires de build s'ils n'existent pas
$(shell mkdir -p $(TEST_BUILD_DIR) $(LIB_BUILD_DIR))

# Compile la librairie partagée pour les threads
lib: $(LIB) $(LIB_OBJ)

$(LIB_BUILD_DIR)/%.so: $(LIB_BUILD_DIR)/%.o
	$(CC) -o $@ -shared -fPIC $^

$(LIB_BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) -o $@ $(CFLAGS) -fPIC -c $< 

# Compiler les tests pour les threads. Chaque test est compilé dans son propre exécutable sans -DUSE_THREAD
tests: $(TEST) $(TEST_OBJ)

$(TEST_BUILD_DIR)/%: $(TEST_BUILD_DIR)/%.o $(LIB)
	$(CC) -o $@ $(CFLAGS) $< -L$(LIB_BUILD_DIR) -lthread -Wl,-rpath=$(INSTALL_LIB_DIR)

$(TEST_BUILD_DIR)/%.o: $(TEST_DIR)/%.c
	$(CC) -o $@ $(CFLAGS) -c $< -I $(SRC_DIR)

# Compiler les tests pour les pthreads. Chaque test est compilé dans son propre exécutable avec -DUSE_PTHREAD
pthreads: $(PTHREAD_TEST) $(PTHREAD_TEST_OBJ)

$(TEST_BUILD_DIR)/%-pthread: $(TEST_BUILD_DIR)/%-pthread.o
	$(CC) -o $@ $(CFLAGS) $< -lpthread -I $(SRC_DIR)

$(TEST_BUILD_DIR)/%-pthread.o: $(TEST_DIR)/%.c
	$(CC) -o $@ $(CFLAGS) -DUSE_PTHREAD -I $(SRC_DIR) -c $< 

# Installation des fichiers cibles dans le répertoire install
install: $(LIB) $(TEST) $(PTHREAD_TEST)
	cp $(LIB) $(INSTALL_LIB_DIR)
	cp $(TEST) $(INSTALL_BIN_DIR)
	cp $(PTHREAD_TEST) $(INSTALL_BIN_DIR)

# Exécution des tests
check:
	./run_tests.sh

# Valgrind
valgrind:
	./run_tests.sh --valgrind

# Suppression du répertoire build et des fichier installés
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(INSTALL_LIB_DIR)/*
	rm -f $(INSTALL_BIN_DIR)/*

.PHONY: all lib tests pthreads install check clean