Ensembl.Panel.ImageMap =  Ensembl.Panel.ImageMap.extend({

  // EG - I can't see why these were here? nickl
  //
  // init: function(){
  //   this.zMenus = [];
  //   this.base();
  // },
  // getContent: function (url, el, params, newContent) {
  //   var i = this.zMenus.length;
  //   while (i--) {
  //     Ensembl.EventManager.trigger('destroyPanel', this.zMenus[i]);
  //   }
  //   this.zMenus = {};
  //   if (newContent && newContent !== true) {
  //     Ensembl.updateURL(newContent); // A link was clicked that needs to add parameters to the url
  //     newContent = false;
  //   }
  //   this.base(url, el, params, newContent);
  // },
  // 
  
  makeZMenu: function (e, coords) {
    var area = coords.r ? this.dragRegion : this.getArea(coords);

    if (!area || $(area.a).hasClass('label')) {
      return;
    }
  
    this.zMenus['zmenu_' + area.a.coords.replace(/[ ,]/g, '_')] = 1;

    this.base(e, coords);
  },
  

  makeImageMap: function () {
    var panel = this;
// EG    
    var highlight = !!(window.location.pathname.match(/\/Location\/|\/Variation_(Gene|Transcript)\/Image/) && !this.vdrag);
//    
    var rect      = [ 'l', 't', 'r', 'b' ];
    var speciesNumber, c, r, start, end, scale;
    
    this.elLk.areas.each(function () {
      c = { a: this };
      
      if (this.shape && this.shape.toLowerCase() !== 'rect') {
        c.c = [];
        $.each(this.coords.split(/[ ,]/), function () { c.c.push(parseInt(this, 10)); });
      } else {
        $.each(this.coords.split(/[ ,]/), function (i) { c[rect[i]] = parseInt(this, 10); });
      }
      
      panel.areas.push(c);
      
      if (this.className.match(/drag/)) {
        // r = [ '#drag', image number, species number, species name, region, start, end, strand ]
        r        = c.a.href.split('|');
        start    = parseInt(r[5], 10);
        end      = parseInt(r[6], 10);
        scale    = (end - start + 1) / (this.vertical ? (c.b - c.t) : (c.r - c.l)); // bps per pixel on image
        
        c.range = { chr: r[4], start: start, end: end, scale: scale, vertical: this.vertical };
        
        panel.draggables.push(c);
        
        if (highlight === true) {
          r = this.href.split('|');
          speciesNumber = parseInt(r[1], 10) - 1;
          
          if (panel.multi || !speciesNumber) {
            if (!panel.highlightRegions[speciesNumber]) {
              panel.highlightRegions[speciesNumber] = [];
              panel.speciesCount++;
            }
            
            panel.highlightRegions[speciesNumber].push({ region: c });
            panel.imageNumber = parseInt(r[2], 10);
            
            Ensembl.images[panel.imageNumber] = Ensembl.images[panel.imageNumber] || {};
            Ensembl.images[panel.imageNumber][speciesNumber] = [ panel.imageNumber, speciesNumber, parseInt(r[5], 10), parseInt(r[6], 10) ];
          }
        }
      }
    });

    if (this.draggables.length) {
      this.labelRight = this.draggables[0].l;  // label ends where the drag region starts
    }

    if (Ensembl.images.total) {
      this.highlightAllImages();
    }
    
    this.elLk.drag.on({
      mousedown: function (e) {

        if (!e.which || e.which === 1) { // Only draw the drag box for left clicks.
          panel.dragStart(e);
        }
        
        return false;
      },
      mousemove: function(e) {

        if (panel.dragging !== false) {
          return;
        }
        
        var area = panel.getArea(panel.getMapCoords(e));
        var tip;

        // change the cursor to pointer for clickable areas
        $(this).toggleClass('drag_select_pointer', !(!area || $(area.a).hasClass('label') || $(area.a).hasClass('drag') || $(area.a).hasClass('hover')));

        // Add helptips on navigation controls in multi species view
        if (area && area.a && $(area.a).hasClass('nav')) {
          if (tip !== area.a.alt) {
            tip = area.a.alt;
            
            if (!panel.elLk.navHelptip) {
              panel.elLk.navHelptip = $('<div class="ui-tooltip helptip-bottom"><div class="ui-tooltip-content"></div></div>');
            }
            
            panel.elLk.navHelptip.children().html(tip).end().appendTo('body').position({
              of: { pageX: panel.imgOffset.left + area.l + 10, pageY: panel.imgOffset.top + area.t - 48, preventDefault: true }, // fake an event
              my: 'center top'
            });
          }
        } else {
          if (panel.elLk.navHelptip) {
            panel.elLk.navHelptip.detach().css({ top: 0, left: 0 });
          }
        }
      },
      mouseleave: function(e) {
        if (e.relatedTarget) {

          if (panel.elLk.navHelptip) {
            panel.elLk.navHelptip.detach();
          }

        }
      },
      click: function (e, e2) {
        if (panel.clicking) {
          panel.makeZMenu(e2 || e, panel.getMapCoords(e2 || e));
        } else {
          panel.clicking = true;
        }
      }
    });
  },
  
  hashChange: function () {
    if (!!window.location.pathname.match(/\/Variation_Gene\/Image/)) {
      if (this.hashChangeReload || this.lastImage) {
        this.elLk.exportMenu.remove();
        Ensembl.Panel.Content.prototype.hashChange.call(this);
      }
      
      Ensembl.EventManager.trigger('highlightAllImages');
    } else {
      this.base.apply(this,arguments);
    }
  }
});