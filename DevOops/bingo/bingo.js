const SQUARES = [
  'Friday deploy',
  'Red pipeline ignored',
  'Manual hotfix',
  'No DB versioning',
  'Snowflake server',
  '"Works on my machine"',
  'Bus factor of one',
  'Unreviewed SQL in prod',
  'No rollback plan',
  'Hidden prod config',
  'Hero deployer',
  'Silo blame',
  'Flaky tests ignored',
  'Runbook in Word',
  'DB change via email',
  'Secrets in repo',
  '"Temporary" forever',
  '1 giant deploy script',
  'No pipeline owner',
  'Direct merge to main',
  'DevOps is a Dev problem',
  '"Fix it after release"',
  'On-call is one person',
  'YAML fan fiction',
];

function shuffle(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function buildGrid() {
  const shuffled = shuffle(SQUARES);
  shuffled.splice(12, 0, 'FREE ⭐');
  return shuffled;
}

const gridEl = document.getElementById('grid');
const squares = buildGrid();
const cells = [];

squares.forEach((text, i) => {
  const cell = document.createElement('div');
  cell.className = 'cell' + (i === 12 ? ' free marked' : '');
  cell.textContent = text;
  cell.dataset.index = i;
  gridEl.appendChild(cell);
  cells.push(cell);
});

const LINES = [
  [0,1,2,3,4],[5,6,7,8,9],[10,11,12,13,14],[15,16,17,18,19],[20,21,22,23,24],
  [0,5,10,15,20],[1,6,11,16,21],[2,7,12,17,22],[3,8,13,18,23],[4,9,14,19,24],
  [0,6,12,18,24],[4,8,12,16,20],
];

function isMarked(i) {
  return cells[i].classList.contains('marked');
}

function checkBingo() {
  for (const line of LINES) {
    if (line.every(isMarked)) {
      line.forEach(i => cells[i].classList.add('bingo-line'));
      document.getElementById('banner').style.display = 'block';
      return;
    }
  }
}

gridEl.addEventListener('click', e => {
  const cell = e.target.closest('.cell');
  if (!cell || cell.classList.contains('free')) return;
  cell.classList.toggle('marked');
  checkBingo();
});
