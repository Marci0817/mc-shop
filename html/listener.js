var limit = {}
var price = {}
var count = {}

var inStorage = {}
var price2 = {}
var count2 = {}
$(function(){
	window.onload = (e) => {
		window.addEventListener('message', (event) => {
			var item = event.data;
			if(item !== undefined && item.type === "openStorage"){
				$("#storage_container").show();
				$("#storageNameShop").text(item.shopData[0]["store_name"])
				$("#storageKereslet").text(item.shopData[0]["kereset"])
				var storageItem = stringTo2dArray(item.shopData[0]["items"], "][",",")
				if(storageItem != ""){
					for (var x = 0; x < storageItem.length; x++) {
						var indexOfitem = 0;
						for (var i = 0; i < item.nagykerAr.length; i++) {
							if(item.nagykerAr[i][0] == storageItem[x][1]){
								indexOfitem = i;
								break;
							}
						}
						inStorage[storageItem[x][1]] = parseFloat(storageItem[x][3]) 
						price2[storageItem[x][1]] = parseFloat(item.nagykerAr[indexOfitem][1])
						count2[storageItem[x][1]] = 1

						$("ul.itemListStorage").append("<li>"+
								"<div class='itemShop' class='"+storageItem[x][1]+"'>"+
									"<img src='img/"+storageItem[x][1]+".png' width='80px' height='' style='float: left;' />"+
									"<span class='leftSpanLee'><b>"+storageItem[x][0]+"</b></span><span class='leftSpanLee'><b>Raktáron: </b><span id='"+ storageItem[x][1] +"' class='instoragenum'>"+inStorage[storageItem[x][1]]+"</span></span><p style='float: right;' class='mennyiseg'>"+
									"<b class='plusStorage "+storageItem[x][1]+"'>+</b>"+
									"<span id='countSt' name='name' > "+count2[storageItem[x][1]]+" </span><span style='color:lightblue;'>db</span><b class='minusStorage "+storageItem[x][1]+"' > -</b></p><br><br>"+
									"<span class='leftSpanLee'><span style='color: green'>$</span> <span class='price' ><input type='number' class='setPriceValue "+ storageItem[x][1] +"' value='"+storageItem[x][2]+"' style='width: 8%;'></span></span> <span class='setPriceButton action "+ storageItem[x][1] +"'  > Beállítás</span></span> "+
									"<p style='float: right;' class='addStorage action' id="+storageItem[x][1]+" >Raktárhoz adás ( $ "+price2[storageItem[x][1]] +" )</p><br><br>"+
									"<span style='float: left;font-size: small;color: red;' >*Amennyiben a termék eltávolításra kerül, a raktáron lévő készlet 50%-os nagykeri áron jóvá lesz írva a bolt számlájára.</span>"+
									"<p style='float: right;' class='removeItem action' id='"+storageItem[x][1]+"'>Termék eltávolítása<span style='color: red;'>*</span></p>"+
								"</div>"+
							"</li><hr>");
					}
				}else{
					$("ul.itemList").append("<div class='itemShop'>"+
						"<p style=''>Ez a bolt üres.</p>"+
						"</div>");
				}

			}
			if(item !== undefined && item.type === "show"){
				$("#container").show();
				$("#shopName").text(item.shopData[0]["store_name"])
				
				var items = stringTo2dArray(item.shopData[0]["items"], "][",",")
				if(items != ""){
					for (var i = 0; i < items.length; i++) {
						limit[items[i][1]] = parseFloat(items[i][3])
						price[items[i][1]] = parseFloat(items[i][2])
						count[items[i][1]] = 1
						var outOfStock = ""
						if(limit[items[i][1]] <= 0){
							outOfStock = "( Nincs raktáron ) "
						}
						$("ul.itemList").append("<li>" +
							"<div class='itemShop'>"+
							"<img src='img/"+items[i][1]+".png' width='80px' height='' style='float: left;' />"+
							"<span class='leftSpanLee'><b>"+items[i][0]+"</b>  <span style='color: red;'>"+outOfStock+"</span> </span><p style='float: right;' class='mennyiseg'>"+
							"<b class='plus "+ items[i][1] +"'>+</b>"+
							"<span id='count' name='name' > "+ count[items[i][1]] +" </span><span style='color:lightblue;'>db</span><b class='minus "+ items[i][1] +"'> -</b></p><br><br>"+
							"<span class='leftSpanLee'><span style='color: green'>$</span> <span class='price' >"+price[items[i][1]]+"</span></span>"+
							"<p style='float: right;' class='buyItem' id='"+ items[i][1] +"'>Vásárlás</p></div></li><hr>" );

					}
				}else{
					$("ul.itemList").append("<div class='itemShop'>"+
						"<p style=''>Ez a bolt üres.</p>"+
						"</div>");
				}
			}

			if(item !== undefined && item.type === "hide"){
				$("#container").hide();
				$("ul.itemList").empty();
				$("ul.itemListStorage").empty();
			}

			$(".plus").on("click", function(){
				//$(".plus").attr('class', '.waitPlusProgress');
				var $button = $(this)
				var classWhichCliked = $(this).attr("class");
				classWhichCliked = classWhichCliked.substring(5)
				var printOut
				if(count[classWhichCliked]+1 <= limit[classWhichCliked]){
					count[classWhichCliked] = count[classWhichCliked] + 1
				}else{
					count[classWhichCliked] = 1
				}
				printOut = price[classWhichCliked] * count[classWhichCliked];
				
				$button.parent().parent().find(".price").text((printOut));
				$button.parent().find("#count").text(" " + count[classWhichCliked] + " ");
				//$(".waitPlusProgress").attr('class', '.plus');

			})
			$(".minus").on("click", function(){
				//$(".minus").attr('class', '.waitMinusProgress');
				var $button = $(this)
				var classWhichCliked = $(this).attr("class");
				classWhichCliked = classWhichCliked.substring(6)
				var printOut
				if(count[classWhichCliked]-1 != 0){
					count[classWhichCliked] = count[classWhichCliked] - 1
				}else{
					count[classWhichCliked] = 1
				}
				printOut = price[classWhichCliked] * count[classWhichCliked];
				$button.parent().parent().find(".price").text((printOut));
				$button.parent().find("#count").text(" " + count[classWhichCliked] + " ");
				//$(".waitMinusProgress").attr('class', '.minus');
			})
			$(".plusStorage").on("click", function(){
				//$(".plusStorage").attr('class', '.waitPlusStorProgress');
				var $button = $(this)
				var classWhichCliked = $(this).attr("class");
				classWhichCliked = classWhichCliked.substring(12)
				var printOut
				count2[classWhichCliked] = count2[classWhichCliked] + 1
				printOut = price2[classWhichCliked] * count2[classWhichCliked];
				$button.parent().parent().find(".addStorage").text(("Raktárhoz adás ( $ "+printOut +" )"));
				$button.parent().find("#countSt").text(" " + count2[classWhichCliked] + " ");
				//$(".waitPlusStorProgress").attr('class', '.plusStorage');

			})
			$(".minusStorage").on("click", function(){
				//$(".minusStorage").attr('class', '.waitMinusStorProgress');
				var $button = $(this)
				var classWhichCliked = $(this).attr("class");
				classWhichCliked = classWhichCliked.substring(13)
				var printOut
				if(count2[classWhichCliked]-1 != 0){
					count2[classWhichCliked] = count2[classWhichCliked] - 1
				}else{
					count2[classWhichCliked] = 1
				}
				printOut = price2[classWhichCliked] * count2[classWhichCliked];
				$button.parent().parent().find(".addStorage").text(("Raktárhoz adás ( $ "+printOut +" )"));
				$button.parent().find("#countSt").text(" " + count2[classWhichCliked] + " ");

				//$(".waitMinusStorProgress").attr('class', '.minusStorage');
			})
			$(".addStorage").on("click", function(){
				//$(".addStorage").attr('class', '.waitAddStorageProgress');
				var $button = $(this);
				const product = $(this).attr("id");
				var raktaronXD = $(".instoragenum").attr("class");
				inStorage[product] = count2[product] + inStorage[product]
				$("."+ raktaronXD+"#"+product).text(inStorage[product]);
				const shopName = $("#storageNameShop").text();
				$.post("http://mc_shop/refreshStorageCount", JSON.stringify({
					product_name: product,
					product_price: price2[product] * count2[product],
					product_count: count2[product],
					product_shopName: shopName
				}))
				//$(".waitAddStorageProgress").attr('class', '.addStorage');
			})
			$(".buyItem").on("click", function(){
				$("#container").removeClass(".buyItem").addClass(".waitBuyItemProgress");
				const product = $(this).attr("id")
				const shopName = $("#shopName").text();
				$.post("http://mc_shop/buyProduct", JSON.stringify({
					product_name: product,
					product_price: price[product] * count[product],
					product_count: count[product],
					product_shopName: shopName
				}))
				$("#container").removeClass(".waitBuyItemProgress").addClass(".buyItem");
			})
			$(".removeItem").on("click", function(){
				//$(".removeItem").attr('class', '.waitRemoveItemProgress');
				const product = $(this).attr("id")
				const shopName = $("#storageNameShop").text();
				$.post("http://mc_shop/removeProduct", JSON.stringify({
					product_name: product,
					product_shopName: shopName
				}))
				$("#storage_container").hide();
			  	$("ul.itemListStorage").empty();
			  	$("ul.itemList").empty();
			  	$.post("http://mc_shop/closeStorage", JSON.stringify({}))
			  	//$(".waitRemoveItemProgress").attr('class', '.removeItem');
			})

			$("#kivetel").on("click", function(){
				//$("#kivetel").attr('id', '#waitKivetelProgress');
				//console.log("clicked")
				const product = $(this).attr("id")
				const shopName = $("#storageNameShop").text();
				$("#storageKereslet").text("0");
				//console.log(".")
				$.post("http://mc_shop/kivetel", JSON.stringify({
					shopName: shopName
				}))
				//$("#waitKivetelProgress").attr('id', '#kivetel');
			})
			$(".setPriceButton").on("click", function(){
				const product = $(this).attr("class")
				const shopName = $("#storageNameShop").text();
				const newValue = $(".setPriceValue."+ product.substring(22)).val();
				$.post("http://mc_shop/setPrice", JSON.stringify({
					product_name: product.substring(22),
					product_newValue: newValue,
					product_shopName: shopName
				}))
			})
			$("#addItem").on("click", function(){
				//const product = $(this).attr("class")
				//$("#addItem").attr('id', '#waitItemAddProgress');
				const shopName = $("#storageNameShop").text();
				const newItemName = $("#valueOfNew").val();
				$.post("http://mc_shop/newItem", JSON.stringify({
					product_newValue: newItemName,
					product_shopName: shopName
				}))
				//$("#waitItemAddProgress").attr('id', '#addItem');
				$("#storage_container").hide();
			  	$("ul.itemListStorage").empty();
			  	$("ul.itemList").empty();
			  	$.post("http://mc_shop/closeStorage", JSON.stringify({}))
			})
			$("#closeThis").click(function(){
			  	$.post("http://mc_shop/closeShop", JSON.stringify({}))
			  	$("#container").hide();
			  	$("ul.itemList").empty();
			})
			$("#closeStorage").click(function(){
				$("#storage_container").hide();
			  	$("ul.itemListStorage").empty();
			  	$("ul.itemList").empty();
			  	$.post("http://mc_shop/closeStorage", JSON.stringify({}))
			})
			
			function stringTo2dArray(string, d1, d2) {
				return string.split(d1).map(function(x){return x.split(d2)});
			}
  		})
  	}
})

//https://javascriptobfuscator.com/Javascript-Obfuscator.aspx
