# Leveraging Geometric Deep Learning for Epidemic Network Reconstruction

This repository contains the code and supporting materials for the manuscript **"Leveraging Geometric Deep Learning for Epidemic Network Reconstruction"**. The project demonstrates a novel approach using Graph Neural Networks (GNNs) to impute sociometric networks among people who inject drugs (PWID), alongside a comparative analysis using Exponential Random Graph Models (ERGMs).

## Dependencies

### Python (GNN Code)
- Python 3.11 or later
- [networkx](https://networkx.org/)
- [numpy](https://numpy.org/)
- [pandas](https://pandas.pydata.org/)
- [torch](https://pytorch.org/)
- [torch_geometric](https://pytorch-geometric.readthedocs.io/en/latest/)
- [matplotlib](https://matplotlib.org/)
- [scikit-learn](https://scikit-learn.org/)
- [scikit-image](https://scikit-image.org/)
- [scipy](https://www.scipy.org/)
- [optuna](https://optuna.org/)
- [pyvis](https://pyvis.readthedocs.io/en/latest/)
- [IPython](https://ipython.org/)

You can install these dependencies using:

```bash
pip install -r requirements.txt
```

### R (ERGM Code)
    - R (version 4.4.2 or later recommended)
	- Packages: tidyverse, ergm.ego, lubridate, igraph, intergraph, matrixStats, mice

Install the required R packages using:

```R
install.packages(c("tidyverse", "lubridate", "igraph", "intergraph", "matrixStats", "mice"))
```

### Setup and Usage

#### GNN (Python)
1.	Data Preparation:
	-	Place your baseline_features.csv and EdgeList_Sociometric.csv files in the GNN/ directory.
	-	These files should include the individual-level node attributes and the sociometric edge list, respectively.

2.	Running the Notebook:
	-	Open the GNN_notebook.ipynb in Jupyter Notebook or JupyterLab.
	-	Execute the cells sequentially. The notebook includes:
	-	Dependency checks and imports.
	-	Data preprocessing (feature scaling, one-hot encoding, handling missing values).
	-	Graph creation using NetworkX and conversion to a PyTorch Geometric Data object.
	-	Splitting the graph into training, validation, and test sets.
	-	Definition and training of the GraphSAGE model with hyperparameter optimization using Optuna.
	-	Network imputation and visualization using PyVis.

3.	Model Evaluation:
	-	The notebook calculates performance metrics (accuracy, precision, recall, F1 score) and plots training/validation loss curves.
	-	The imputed network can be visualized interactively using the provided plotting functions.

#### ERGM (R)
1.	Data Preparation:
	-	Place your baseline_data.rds and EdgeList_Sociometric.csv files in the ERGM/ directory.
	-	Ensure that the data is formatted as required by the script.

2.	Running the Script:
	-	Open the ERGM_script.R in RStudio or run it from the R console.
	-	The script:
	-	Loads and preprocesses baseline survey data and constructs the sociometric network.
	-	Handles missing data using the mice package.
	-	Converts the full network into an egocentric network format.
	-	Specifies ERGM terms (including nodematch, nodefactor, and nodecov) and fits an egocentric ERGM.
	-	Simulates 500 networks and computes summary statistics (density, average distance, diameter, transitivity, degree distributions) for comparison with the observed network.
	-	Also fits a simple Erdős–Rényi model as a benchmark.