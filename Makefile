CC:=gcc
#CFLAGS:=-I./src -std=gnu99 -O2
CFLAGS:=-I./src -std=gnu99 -Og -ggdb3 -Wall -Wextra

#LEX:=lex
#LEXFLAG:=-ll
LEX:=flex
LEXFLAG:=-lfl

OBJDIR:=obj
OBJS:=$(OBJDIR)/lex.yy.o $(OBJDIR)/driver.o
BIN:=$(OBJDIR)/scanner

.PHONY: clean test $(OBJS) $(BIN)

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LEXFLAG)

$(OBJDIR)/lex.yy.o: $(OBJDIR)/lex.yy.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/lex.yy.c: src/scanner.l | $(OBJDIR)
	$(LEX) -o $@ $<

$(OBJDIR)/driver.o: src/driver.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJDIR)

$(OBJDIR):
	mkdir $@

test: $(BIN) test/run_tests.sh
	bash test/run_tests.sh $<

# vim: noexpandtab
