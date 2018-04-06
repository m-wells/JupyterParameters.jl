# Julia Jupyter NoteBook PARAMeterizer (jjnbparam)
Running batch jobs in Jupyter notebooks can be quite useful.
The main reason I want to do this is so I can have beautiful "log" files of my data analysis, complete with inline plots using [PyPlot](https://github.com/JuliaPy/PyPlot.jl).

Running Jupyter notebooks from the command line is already possible using
```
jupyter nbconvert --to notebook --execute mynotebook.ipynb
```
The issue with using `nbconvert` in this fashion, is you **_can not pass arguments to the notebook_**.

Using `jjnbparam` you are able to pass in variables to a notebook.
```
jjnbparam notebook_orig.ipynb notebook_new.ipynb --varname1 varvalue1 --varname2 varvalue2 ...
```
The command above creates and executes a new copy of the notebook with the parameters that have been passed and preserves the original.
If one wants to overwrite the original then 
```
jjnbparam notebook.ipynb notebook.ipynb --varname1 varvalue1 --varname2 varvalue2 ...
```

The target notebook needs to include a `parameters` cell:
![Example of a tagged parameters cell](https://github.com/m-wells/jjnbparam/blob/master/parameters_cell_tagging.png)

This project was inspired by [papermill](https://github.com/nteract/papermill)

# TODO:
Create a Makefile to simplify installation.
