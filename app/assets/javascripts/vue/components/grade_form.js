//= require vue-select
var GradeForm = {
  props:['subjects','grade'],
   components: {
    'v-select': VueSelect.VueSelect,
  },

  template: `
<form>
  <table>
    <tbody>
      <tr>
        <td>
       <v-select label="name" v-model="selected" taggable push-tags placeholder="Select one" v-on:input="doChanged" :options="subjects"></v-select>
<span>Selected: {{selected.name}}</span>
        </td>
        <td>
          <input type="text" v-model="grade.value" placeholder="Grade" id="grade" name="value">
        </td>
      </tr>
  </table>
<div>{{grade.errMsg}}</div>
</form>
  `,

  data: function(){
    return{
      selected: {},
    }
  },
  methods: {
    doChanged: function(e){
      if(e !== null){
        this.grade.id = e.id;
        this.grade.subject_name = e.name;
      }else{
        this.selected= {id: "", name: ""};
      }
    },
  }
};

