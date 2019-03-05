# Julia Jupyter NoteBook PARAMeterizer
Running batch jobs in Jupyter notebooks can be quite useful.
The main reason I want to do this is so I can have beautiful "log" files of my data analysis, complete with inline plots using [PyPlot](https://github.com/JuliaPy/PyPlot.jl).

Running Jupyter notebooks from the command line is already possible using
```
jupyter nbconvert --to notebook --execute mynotebook.ipynb
```
The issue with using `nbconvert` in this fashion, is you **_can not pass arguments to the notebook_**.

Using `jjnbparam` you are able to pass variables to a notebook.
```
jjnbparam notebook_orig.ipynb notebook_new.ipynb --varname1 varvalue1 --varname2 varvalue2 ...
```
The command above creates and executes a new copy of the notebook with the parameters that have been passed and preserves the original.
If one wants to overwrite the original then 
```
jjnbparam notebook.ipynb notebook.ipynb --varname1 varvalue1 --varname2 varvalue2 ...
```

The target notebook needs to include a `parameters` cell (this does not have to be the first cell):
![Example of a tagged parameters cell](https://github.com/m-wells/jjnbparam/blob/master/parameters_cell_tagging.png)
To create a parameters cell simply edit the cell's metadata to include the following:
```json
{
    "tags": [
        "parameters"
    ]
}
```
It is also helpful to have a comment inside of the cell like so
```julia
# this is the parameters cell
foo = 10
bar = "hi"
```
In the cell above `foo` and `bar` are defined with what can be thought of as default values which will be used if the user does not replace them.


This project was inspired by [papermill](https://github.com/nteract/papermill)

# Installation
```
cd <your build directory>
git clone https://github.com/m-wells/jjnbparam
make
```
Then add `jjnbparam` to your path (if you want).
