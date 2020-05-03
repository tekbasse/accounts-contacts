<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <h1>@title;noquote@</h1>

  <if @confirmed_open@ not nil>
  @confirmed_open;noquote@
  </if>
  
  <if @confirmed1@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@confirmed1;noquote@>
  </if>
  
  <if @confirmed2@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@confirmed2;noquote@>
  </if>
  
  <if @confirmed3@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@confirmed3;noquote@>
  </if>
  
  <if @confirmed4@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@confirmed4;noquote@>    
  </if>
  
  <if @confirmed5@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@confirmed5;noquote@>
  </if>
  <if @confirmed_close@ not nil>
    @confirmed_close;noquote@
  </if>

  
  @content_c_open;noquote@
  
  <if @content_c1@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@content_c1;noquote@>
  </if>
  
  <if @content_c2@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@content_c2;noquote@>
  </if>
  
  <if @content_c3@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@content_c3;noquote@>
  </if>
  
  <if @content_c4@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@content_c4;noquote@>    
  </if>
  
  <if @content_c5@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@content_c5;noquote@>
  </if>

  <if @content_c6@ not nil and @contact_id@ not nil>

    <include src="/packages/accounts-contacts/lib/page-runner-block-1col" content_c1=@content_c6;noquote@>
  </if>

  @content_c_close;noquote@




