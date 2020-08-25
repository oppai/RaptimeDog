<template>
  <div>
    <h1>RaptimeTools</h1>
    <div class="race-list">
      <div v-for="(horse, idx1) in horse_list" :key="idx1">
        <h2>{{ horse.num || 'x' }}番 {{ horse.name }} / {{ horse.data.info }}</h2>
        <ul>
          <h4>データ</h4>
          <li>平均3ハロン: {{ avgFurlong(horse.data.records) }}sec </li>
          <h4>過去レース</h4>
          <li v-for="(record, idx2) in horse.data.records" :key="idx2">
            {{ record.date }}, {{ record.race_info.type }}, {{ record.race_info.length}}m, {{ record.time }}sec
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
var Decimal = require('decimal.js');

export default {
  data() {
    return {
      horse_list: []
    }
  },
  mounted() {
    this.axios
      .get('http://localhost:8080/race.json')
      .then(res => {
        this.horse_list = res.data.data
      })
  },
  methods: {
    avgFurlong(records) {
      const turfs = records.filter(record => record.race_info.type == "芝").slice(5);
      if (turfs.length <= 0) {
        return 0;
      }
      const avg = turfs.map(race => {
        const time = new Decimal(race.time);
        const length = new Decimal(race.race_info.length);
        return time.dividedBy(length).times(200);
      }).reduce(
        (sum, current) => sum.plus(current)
      ).dividedBy(turfs.length);
      return avg.times(3).toFixed(2);
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
