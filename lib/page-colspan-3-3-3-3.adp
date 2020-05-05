<!-- ESRG uses 12 units per whole pagewidth -->
<!-- This is appropriate for Balance Sheet report and the like -->
<div class="grid-whole equalize">
  <div class="grid-3 m-grid-6 s-grid-12 padded">
    <div class="padded-inner content-box">
      <if @content_c1 not nil>
        @content_c1;noquote@
      </if>
    </div>
  </div>
  <div class="grid-3 m-grid-6 s-grid-12 padded">
    <div class="padded-inner content-box">
      <if @content_c2 not nil>
        @content_c2;noquote@
      </if>
    </div>
  </div>
</div>
<div class="grid-whole equalize">
  <div class="grid-3 m-grid-6 s-grid-12 padded">
    <div class="padded-inner content-box">
      <if @content_c3 not nil>
        @content_c3;noquote@
      </if>
    </div>
  </div>
  <div class="grid-3 m-grid-6 s-grid-12 padded">
    <div class="padded-inner content-box">
      <if @content_c4 not nil>
        @content_c4;noquote@
      </if>
    </div>
  </div>
</div>
