# CIQ Py

Python utility script to manipulate CIQ application (PRG files). It can be extended to change the content of its sections. It automatically computes a new valid signature so that the modified PRG file can be run on the watch.

Example:

```console
$ python3 main.py -d ./developer_key -f ./app.prg
$ python3 main.py -d ./developer_key -f ./app.prg -o ./modified_app.prg
```

The script uses the Katai structure defined in `ciq.ksy`, which can be compiled to Python using `kaitai-struct-compiler --target python ciq.ksy`. See [Kaitai documentation](https://doc.kaitai.io/lang_python.html) for more information.