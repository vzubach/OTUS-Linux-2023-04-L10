#!/bin/bash

ACCSSTRTIME=$(head -n1 /home/falcon/OTUS-Linux-2023-04-L10/access.log | egrep -o "[0-9]{2}\/[A-Za-z]{3}\/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}" | sed -e "s/\//\-/g" | sed -e "s/:/\ /$1")
ACCSSENDTIME=$(tail -n1 /home/falcon/OTUS-Linux-2023-04-L10/access.log | egrep -o "[0-9]{2}\/[A-Za-z]{3}\/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}" | sed -e "s/\//\-/g" | sed -e "s/:/\ /$1")

ERRSTRTTIME=$(egrep -o ">.*\[error\].*<" /home/falcon/OTUS-Linux-2023-04-L10/error.log | egrep -o "[0-9]{4}\/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}" | head -n1 | sed -e "s/\//\-/g")
ERRENDTIME=$(egrep -o ">.*\[error\].*<" /home/falcon/OTUS-Linux-2023-04-L10/error.log | egrep -o "[0-9]{4}\/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}" | tail -n1 | sed -e "s/\//\-/g")

URLS=$(egrep -o "(http[s]?:\/\/(www\.)?\w+\.[a-zA-Z]{2,5}|http[s]?:\/\/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})" /home/falcon/OTUS-Linux-2023-04-L10/access.log | sort | uniq -c | sort -n)
IPADDR=$(awk '{print $1}' /home/falcon/OTUS-Linux-2023-04-L10/access.log | uniq -c | sort -n | tail)
ERRCODES=$(egrep -o "HTTP\/1\.1\" [0-9]{3}" /home/falcon/OTUS-Linux-2023-04-L10/access.log | awk '{print $2}' | sort | uniq -c | sort -n)

ERRLOGS=$(egrep -o ">.*\[error\].*<" /home/falcon/OTUS-Linux-2023-04-L10/error.log)

sendemail -f "linuxtest@gmail.com" -t "exemple@domain.ru" -u "Периодическая статистика работы NGINX" -s "smtp.gmail.com" -o tls=yes -xu "username" -xp "password" -m "Список URL с количеством посещений за период с $ACCSSTRTIME по $ACCSSENDTIME:
\n$URLS\n\nСписок IP-адресов с наибольшим кол-ом посещний за период с $ACCSSTRTIME по $ACCSSENDTIME:\n\n$IPADDR\n
\nСписок кодов ошибок с их колл-вом за период с $ACCSSTRTIME по $ACCSSENDTIME:\n\n$ERRCODES\n\nЛоги с ошибками за период с $ERRSTRTTIME по $ERRENDTIME:\n\n$ERRLOGS" -o message-charset=UTF-8

cat /home/falcon/OTUS-Linux-2023-04-L10/access.log >> /home/falcon/OTUS-Linux-2023-04-L10/access.log.bkp
cat /home/falcon/OTUS-Linux-2023-04-L10/error.log >> /home/falcon/OTUS-Linux-2023-04-L10/error.log.bkp

rm -f /home/falcon/OTUS-Linux-2023-04-L10/access.log
rm -f /home/falcon/OTUS-Linux-2023-04-L10/error.log