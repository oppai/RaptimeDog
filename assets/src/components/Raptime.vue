<template>
  <div>
    <h1>RaptimeTools</h1>
    <div class="race-input">
      <input v-model="url" placeholder="input keibanet url" />
      <button v-on:click="getRaceData"> check </button>
    </div>
    <div v-show="loading">
      <vue-loading 
        type="spiningDubbles"
        color="#aaa"
        :size="{ width: '100px', height: '100px' }"
        >
      </vue-loading>
    </div>
    <div v-if="race">
      <h3>{{ getRaceTitle(race) }}</h3>
      <div class="horse-list">
        <table class="horse-table">
          <thead>
            <tr>
              <th>番号</th>
              <th>名前</th>
              <th>直5レース1F</th>
              <th>直10レース1F</th>
              <th>ダ含み直10レース1F</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(horse, idx1) in race.horses" :key="idx1">
              <td> {{ horse.num || '-' }} </td>
              <td> <a target="_blank" v-bind:href="horse.url">{{ horse.name }}</a> </td>
              <td> {{ avgFurlong(horse.data.records, 5) }}s </td>
              <td> {{ avgFurlong(horse.data.records, 10) }}s </td>
              <td> {{ avgFurlong(horse.data.records, 10, false) }}s </td>
            </tr>
          </tbody>
        </table>
        <div v-for="(horse, idx1) in race.horses" :key="idx1">
          <div class="horse-title">
            {{ horse.num || 'x' }}番 {{ horse.name }} / {{ horse.data.info }}
          </div>
          <div class="horse-data">
            <div class="horse-basic-data">
              <ul>
                <li>直近5レースの平均1ハロン: {{ avgFurlong(horse.data.records, 5) }}sec </li>
                <li>直近10レースの平均1ハロン: {{ avgFurlong(horse.data.records, 10) }}sec </li>
              </ul>
            </div>
            <div class="horse-race-data">
              <h4>過去レース</h4>
              <ul>
                <li v-for="(record, idx2) in horse.data.records" :key="idx2">
                  {{ record.date }}, {{ record.place }}, {{ record.race_info.type }}, {{ record.race_info.length}}m, {{ record.time }}sec
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { VueLoading } from 'vue-loading-template'
var Decimal = require('decimal.js');

export default {
  data() {
    return {
      url: "",
      race: null,
      loading: false
    }
  },
  mounted() {
    this.url = this.$route.query.url || "";
  },
  methods: {
    getRaceData() {
      if (this.url == "") return;
      console.log(this.url);
      this.loading = true
      this.axios
      .get(`/api/detail?url=${this.url}`)
      .then(res => {
        this.race = res.data.data
        this.loading = false
      })
    },
    getRaceTitle(race) {
      return race.race_detail[1] + ' ' + race.race_detail[2] + ' ' + race.race_num + ':' + race.race_name + ' - ' + race.race_field
    },
    avgFurlong(records, num, turfOnly = true) {
      const turfs = records.filter(record =>(
        turfOnly ? record.race_info.type == "芝" : true
      )).slice(0, num);
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
      return avg.toFixed(2);
    }
  },
  components: {
    VueLoading
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.race-input input {
  width: 400px;
}
.horse-title {
  font-size: 24px;
  margin-top: 50px;
  margin-bottom: 0px;
}
.horse-table {
  margin-left: auto;
  margin-right: auto;
}
.horse-data {
  margin-top: 0px;
  display: inline-flex;
}
.horse-basic-data {
  max-width: 50%;
}
.horse-race-data {
  max-width: 50%;
}
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
