document.addEventListener('DOMContentLoaded', function () {
  new Vue({
    el: '#app',
    data: function() {
      return {
        devices: [],
        page_info: {},
        order_column: 'metadata->>\'last_seen\'',
        order_desc: true
      };
    },
    computed: {
      hasPrev: function() {
        return this.page_info.current_page > 1;
      },
      hasNext: function() {
        return this.page_info.current_page < this.page_info.total_pages;
      },
      order: function() {
        return this.order_column + ' ' + (this.order_desc ? 'DESC' : 'ASC')
      }
    },
    beforeMount: function() {
      this.fetchData(1, 'metadata->>\'last_seen\' DESC');
    },
    methods: {
      fetchData: function(page) {
        var data = this.$data;
        fetch('/device_story/devices.json?page=' + page + '&order=' + this.order)
          .then(function(response) {
            return response.json();
          })
          .then(function(json) {
            data.devices = json.data.devices;
            data.page_info = json.data.page_info;
          });
      },
      prevPage: function(_event) {
        this.fetchData(this.page_info.current_page - 1);
      },
      nextPage: function(_event) {
        this.fetchData(this.page_info.current_page + 1);
      },
      toggleLastSeenSort: function(_event) {
        this.order_desc = !this.order_desc;
        this.fetchData(1);
      }
    }
  })
})
