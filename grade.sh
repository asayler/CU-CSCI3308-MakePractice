#!/usr/bin/env bash

EXIT_FAILURE=1
EXIT_SUCCESS=0

grade=2

echoerr() { echo "$@" 1>&2; }


# Find code
loc="$(dirname "$(find ./ -type f -iname 'Makefile' | head -1)")"
if [[ $? -ne 0 ]]
then
    echoerr "Could not find code"
    exit ${EXIT_FAILURE}
fi

# Jump to code dir
pushd "${loc}" &> /dev/null
if [[ $? -ne 0 ]]
then
    echoerr "pushd failed"
    exit ${EXIT_FAILURE}
fi

# Convert files to Unix format
dos2unix * &> /dev/null
if [[ $? -ne 0 ]]
then
    echoerr "dos2unix failed"
    exit ${EXIT_FAILURE}
fi

# Clean
rm -f *.a *.o facts1 facts2

# Build Libs
make libs &> /dev/null
if [[ $? -ne 0 ]]
then
    make lib &> /dev/null
    if [[ $? -ne 0 ]]
    then
        echoerr "make libs failed"
        exit ${EXIT_FAILURE}
    fi
fi

# Check for targets
if [[ ! -f facts1 && ! -f facts2 ]]
then
    grade=$((${grade} + 1))
else
    echoerr "facts present in libs build"
fi

if [[ -f libfunnyfacts1.a || -f libFunnyFacts1.a ]]
then
    grade=$((${grade} + 1))
else
    echoerr "Missing libfunnyfacts1.a"
fi

if [[ -f libfunnyfacts2.a || -f libFunnyFacts2.a ]]
then
    grade=$((${grade} + 1))
else
    echoerr "Missing libfunnyfacts2.a"
fi

# Clean
rm -f *.a *.o facts1 facts2

# Build All
make all &> /dev/null
if [[ $? -ne 0 ]]
then
    echoerr "make all failed"
    exit ${EXIT_FAILURE}
fi

# Check for targets
if [[ -f facts1 ]]
then
    grade=$((${grade} + 1))
else
    echoerr "Missing facts1"
fi

if [[ -f facts2 ]]
then
    grade=$((${grade} + 1))
else
    echoerr "Missing facts2"
fi

# Clean
make clean &> /dev/null
if [[ $? -ne 0 ]]
then
    echoerr "make clean failed"
    exit ${EXIT_FAILURE}
fi

# Check for targets
if [[ ! -f facts1 && ! -f facts2 ]]
then
    grade=$((${grade} + 1))
else
    echoerr "facts still present"
fi

ars=$(ls -l *.a 2> /dev/null | wc -l)
if [[ ${ars} -eq 0 ]]
then
    grade=$((${grade} + 1))
else
    echoerr "Archive files still present"
fi

obj=$(ls -l *.o 2> /dev/null | wc -l)
if [[ ${obj} -eq 0 ]]
then
    grade=$((${grade} + 1))
else
    echoerr "Object files still present"
fi

# Return to orig dir
popd &> /dev/null
if [[ $? -ne 0 ]]
then
    echoerr "popd failed"
    exit ${EXIT_FAILURE}
fi

# Output grade
echo ${grade}
exit ${EXIT_SUCCESS}
