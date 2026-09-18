/* 紙與墨 — 主題切換（三態：system / light / dark）
   跨頁共用 localStorage['class-theme']；GitHub Pages 全站同源。
   防閃爍腳本另見 design/page-template.html 的 <head>，必須在 CSS 之前執行。 */
(function(){
  var KEY='class-theme';
  var order=['system','light','dark'];
  var label={system:'☾ 自動',light:'☾ 深色',dark:'☀ 淺色'};
  var title={system:'目前跟隨系統，點擊改為淺色',light:'目前淺色，點擊改為深色',dark:'目前深色，點擊改為自動'};

  function get(){ try{ return localStorage.getItem(KEY)||'system'; }catch(e){ return 'system'; } }
  function apply(v){
    var r=document.documentElement;
    if(v==='system'){ r.removeAttribute('data-theme'); } else { r.setAttribute('data-theme',v); }
    document.querySelectorAll('[data-theme-toggle]').forEach(function(b){
      b.textContent=label[v]; b.setAttribute('title',title[v]); b.setAttribute('aria-label',title[v]);
    });
  }
  function set(v){ try{ localStorage.setItem(KEY,v); }catch(e){} apply(v); }

  document.addEventListener('click',function(e){
    var b=e.target.closest('[data-theme-toggle]'); if(!b) return;
    set(order[(order.indexOf(get())+1)%order.length]);
  });
  // 其他分頁切換時同步
  window.addEventListener('storage',function(e){ if(e.key===KEY) apply(get()); });
  apply(get());
})();
