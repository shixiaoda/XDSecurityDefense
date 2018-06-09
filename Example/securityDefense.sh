
#!/usr/bin/env bash

TABLENAME=symbols
SYMBOL_DB_FILE="symbols"
STRING_SYMBOL_FILE="func.list"
#HEAD_FILE="$PROJECT_DIR/$PROJECT_NAME/XDSecurityDefense.h"
#HEAD_FILE="$PROJECT_DIR/Pods/XDSecurityDefense/Classes/XDSecurityDefense.h"
HEAD_FILE="$PROJECT_DIR/../XDSecurityDefense/Classes/XDSecurityDefense.h"
export LC_CTYPE=C

#维护数据库方便日后作排重
createTable()
{
echo "create table $TABLENAME(src text, des text);" | sqlite3 $SYMBOL_DB_FILE
}

insertValue()
{
echo "insert into $TABLENAME values('$1' ,'$2');" | sqlite3 $SYMBOL_DB_FILE
}

query()
{
echo "select * from $TABLENAME where src='$1';" | sqlite3 $SYMBOL_DB_FILE
}

ramdomString()
{
openssl rand -base64 64 | tr -cd 'A-Z' |head -c 3
}

ramdomString2()
{
openssl rand -base64 64 | tr -cd 'A-Z' |head -c 3
}

rm -f $SYMBOL_DB_FILE
rm -f $HEAD_FILE
createTable

touch $HEAD_FILE
echo '#ifndef Demo_codeObfuscation_h
#define Demo_codeObfuscation_h' >> $HEAD_FILE
echo "//confuse string at `date`" >> $HEAD_FILE
cat "$STRING_SYMBOL_FILE" | while read -ra line; do
if [[ ! -z "$line" ]]; then
ramdom=`ramdomString`
ramdom2=`ramdomString2`
echo $line $ramdom${line}$ramdom2
insertValue $line $ramdom${line}$ramdom2
echo "#define $line $ramdom${line}$ramdom2" >> $HEAD_FILE
fi
done
echo "#endif" >> $HEAD_FILE


sqlite3 $SYMBOL_DB_FILE .dump
