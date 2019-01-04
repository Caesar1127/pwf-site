//= require ./grade_form
//= require ./grade_table

var ReportCard ={
  components: {
    'grade-form': GradeForm,
    'grade-table': GradeTable,
  },

template: `<div class="grades-panel"> 
  <grade-form v-bind:subjects="subjects" v-bind:grade="grade" v-on:graded="addGrade(grade)" ></grade-form>
  <grade-table v-bind:propgrades="grades" v-on:delete="deleteEvent"> </grade-table>
</div>`,

  data: function() {
    return {
      grade: {
        id:"",
        subject_name: "",
        value: "",
        score: "",
        errMsg: ""
      },
      grades: [],
      subjects: []
    };
  },

  mounted: function(){
    let el = document.getElementsByClassName("report-card")[0];
    this.getPath = el.getAttribute('data-reportcard-get-path');
    this.postPath = el.getAttribute('data-reportcard-post-path');
    this.loadGrades();
  },

  methods: {
    loadGrades: function(){
      axios.get(this.getPath,{reponseType: 'json'})
        .then(function (response) {
          this.grades = response.data.grades;
          this.subjects = response.data.subject_list;
        }.bind(this))
        .catch(function (error) {
        })
    },

    addGrade: function(event){
      let url = this.postPath;
      axios.post(url,this.grade, {reponseType: 'json'})
        .then(function (response) {
          this.addRow();
        }.bind(this))
        .catch(function (error) {
          this.grade.errMsg = error.response.headers["x-message"];
        }.bind(this))
    },

    addRow: function () {
      var newRow={
        subject_name: this.grade.subject_name,
        value: this.grade.value,
        score: ''
      };

      this.grades.push( newRow );
    },
    deleteEvent: function(index) {
      this.grades.splice(index, 1);
    }
  }
};


