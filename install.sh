echo $(realpath $0)
dname=$(dirname $(realpath $0))
python3.12 -m "venv" ${dname}/.venv
${dname}/.venv/bin/pip install -e ${dname}/python/astral_body
