import gas from './cache/gas.json';

let table = `<table>`;
gas.map((item) => {
  let row = `
    <tr>
      <th colspan="4">Contract</th>
      <th>gas</th>
      <th>size</th>
    </tr>
    <tr>
      <td colspan="4"><b>${item.contract}</b></td>
      <td>${item.deployment.gas}</td>
      <td>${item.deployment.size}</td>
    </tr>
    <tr>
      <th>Method</th>
      <th>min</th>
      <th>mean</th>
      <th>median</th>
      <th>max</th>
      <th>calls</th>
    </tr>`;
  Object.entries(item.functions).map(([method, values]) => {
    row += `
    <tr>
      <td>${method}</td>
      <td>${values.min}</td>
      <td>${values.mean}</td>
      <td>${values.median}</td>
      <td>${values.max}</td>
      <td>${values.calls}</td>
    </tr>`;
  });
  table += row;
});
table += `</table>`;

console.log(table);
