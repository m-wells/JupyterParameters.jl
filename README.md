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
It is also helpful (for the user) to have a comment inside of the cell like so
```julia
# this is the parameters cell
foo = 10
bar = "hi"
```
In the cell above `foo` and `bar` are defined with what can be thought of as default values which will be used if the user does not replace them.

This project was inspired by [papermill](https://github.com/nteract/papermill)

## Customizing Notebook Execution
The execution of the notebook can be customized with
```sh
jjnbparam refnote.ipynb outnote.ipynb \
    --kernel_name julia-nodeps-1.1 \
    --timeout -1 \
    --var1 1234 \
    --var2 "abcd"
```
where `kernel_name` specifies the [IJulia](https://github.com/JuliaLang/IJulia.jl) kernel and timeout defines the maximum time (in seconds) each notebook cell is allowed to run.
These values are passed under-the-hood to `jupyter nbconvert` as [traitlets](https://nbconvert.readthedocs.io/en/latest/execute_api.html#execution-arguments-traitlets).
If not passed the default values for `jupyter nbconvert` are used (again, see [traitlets](https://nbconvert.readthedocs.io/en/latest/execute_api.html#execution-arguments-traitlets)).

# Installation
```
cd <your build directory>
git clone https://github.com/m-wells/jjnbparam
make
```
Then add `jjnbparam` to your path (if you want).
