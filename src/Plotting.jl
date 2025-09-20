module PortfolioOptimiser

using PyCall

function plot_hist(
    portfolio::Portfolio;
    tickers::Union{String, Vector{String}} = portfolio.tickers,
    returns_col::String = "returns",
    kwargs...,
)
    plt = pyimport("matplotlib.pyplot")
    sns = pyimport("seaborn")

    if isa(tickers, String)
        tickers = [tickers]
    end

    n = length(tickers)
    cols = 2
    rows = ceil(Int, n / cols)

    fig, axes = plt.subplots(rows, cols; figsize=(15, 5 * rows))
    axes = axes |> x -> x[:].tolist() |> x -> x[!isnothing(x)]

    for (i, ticker) in enumerate(tickers)
        ax = axes[i]
        data = portfolio.data[portfolio.data.ticker .== ticker, :]
        sns.histplot(data[!, returns_col], ax=ax, kde=true, color="blue")
        ax.set_title("Histogram of Returns for $ticker")
        ax.set_xlabel("Returns")
        ax.set_ylabel("Frequency")
    end

    plt.tight_layout()
    plt.show()
end

function plot_range(
    portfolio::Portfolio;
    tickers::Union{String, Vector{String}} = portfolio.tickers,
    kwargs...,
)
    plt = pyimport("matplotlib.pyplot")
    sns = pyimport("seaborn")

    if isa(tickers, String)
        tickers = [tickers]
    end

    n = length(tickers)
    cols = 2
    rows = ceil(Int, n / cols)

    fig, axes = plt.subplots(rows, cols; figsize=(15, 5 * rows))
    axes = axes |> x -> x[:].tolist() |> x -> x[!isnothing(x)]

    for (i, ticker) in enumerate(tickers)
        ax = axes[i]
        data = portfolio.data[portfolio.data.ticker .== ticker, :]
        sns.lineplot(data=data, x="date", y="returns", ax=ax, label="Actual Returns")
        sns.lineplot(data=data, x="date", y="predicted_returns", ax=ax, label="Predicted Returns", linestyle="--")
        ax.set_title("Returns Range for $ticker")
        ax.set_xlabel("Date")
        ax.set_ylabel("Returns")
        ax.legend()
    end

    plt.tight_layout()
    plt.show()
end

function plot_box(
    portfolio::Portfolio;
    tickers::Union{String, Vector{String}} = portfolio.tickers,
    kwargs...,
)
    plt = pyimport("matplotlib.pyplot")
    sns = pyimport("seaborn")

    if isa(tickers, String)
        tickers = [tickers]
    end

    n = length(tickers)
    cols = 2
    rows = ceil(Int, n / cols)

    fig, axes = plt.subplots(rows, cols; figsize=(15, 5 * rows))
    axes = axes |> x -> x[:].tolist() |> x -> x[!isnothing(x)]

    for (i, ticker) in enumerate(tickers)
        ax = axes[i]
        data = portfolio.data[portfolio.data.ticker .== ticker, :]
        sns.boxplot(data=data, x="ticker", y="returns", ax=ax)
        ax.set_title("Box Plot of Returns for $ticker")
        ax.set_xlabel("Ticker")
        ax.set_ylabel("Returns")
    end

    plt.tight_layout()
    plt.show()
end

function plot_network(
    portfolio::Portfolio;
    method::Symbol = :corr,
    nodes::Int = 0,
    kwargs...,
)
    plt = pyimport("matplotlib.pyplot")
    nx = pyimport("networkx")

    if method == :corr
        corr = portfolio.corr
        g = nx.from_pandas_adjacency(corr)
    else
        error("Unsupported method: $method")
    end

    pos = nx.spring_layout(g)
    plt.figure(figsize=(10, 10))
    nx.draw_networkx_nodes(g, pos, node_size=700)
    nx.draw_networkx_edges(g, pos, width=1.0, alpha=0.5)
    nx.draw_networkx_labels(g, pos, font_size=12)

    plt.title("Network Graph of Asset Correlations")
    plt.axis("off")
    plt.show()
end

function plot_clusters(
    portfolio::Portfolio;
    method::Symbol = :corr,
    nodes::Int = 0,
    kwargs...,
)
    plt = pyimport("matplotlib.pyplot")
    nx = pyimport("networkx")
    community = pyimport("community")

    if method == :corr
        corr = portfolio.corr
        g = nx.from_pandas_adjacency(corr)
        partition = community.best_partition(g)
    else
        error("Unsupported method: $method")
    end

    plt.figure(figsize=(10, 10))
    nx.draw_networkx_nodes(g, pos, node_size=700, cmap=plt.cm.RdYlBu, node_color=collect(partition.values()))
    nx.draw_networkx_edges(g, pos, width=1.0, alpha=0.5)
    nx.draw_networkx_labels(g, pos, font_size=12)

    plt.title("Clusters of Assets Based on Correlation")
    plt.axis("off")
    plt.show()
end

end