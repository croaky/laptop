# Load Testing

Install [Vegeta].
On macOS:

```
brew update && brew install vegeta
```

[Vegeta]:https://github.com/tsenart/vegeta

See help file:

```
vegeta
```

Perform a load test:

```
echo "GET https://www.statusok.com/" | \
  vegeta attack -duration=5s | \
  vegeta report
```

See output:

```
Requests     [total, rate]           250, 50.20
Duration     [total, attack, wait]   5.2s, 4.9s, 274.6ms
Latencies    [mean, 50, 95, 99, max] 260.9ms, 258.0ms, 278.7ms, 313.9ms, 388.9ms
Bytes In     [total, mean]           4243250, 16973.00
Bytes Out    [total, mean]           0, 0.00
Success      [ratio]                 100.00%
Status Codes [code:count]            200:250
Error Set:
```

Install [Dygraphs]:

[Dygraphs]: http://dygraphs.com/

```
npm install --save dygraphs
```

Change the flags on the `report` subcommand for graph output:

```
echo "GET https://www.statusok.com/" | \
  vegeta attack -duration=5s | \
  vegeta report -reporter=plot -output=report.html
open report.html
```

See the graph:

![vegeta-plot](https://cloud.githubusercontent.com/assets/198/23337557/025873ce-fba7-11e6-869e-06b68be55eac.png)
